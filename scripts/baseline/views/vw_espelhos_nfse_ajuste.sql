-- ============================================================
-- BASELINE: dbo.vw_espelhos_nfse_ajuste
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_espelhos_nfse_ajuste]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_espelhos_nfse_ajuste]
as
SELECT
    espelhos.mtn_cd_motorista_nfs AS CodigoEspelho,
    espelhos.mtn_nome_motorista AS Motorista,
    espelhos.mtn_cod_cliente AS CodigoCliente,
    espelhos.mtn_cd_pgto_periodo AS CodigoPeriodo,
    CAST(ISNULL(espelhos.mtn_vl_nfs,0) AS FLOAT) AS ValorEspelho,
    CAST(ISNULL(notas.enf_vl_nota,0) AS FLOAT) AS ValorNota,
    FORMAT(espelhos.mtn_dh_criacao,'dd/MM/yyyy HH:mm:ss') AS DataHoraEspelho,
    FORMAT(notas.enf_dh_emissao,'dd/MM/yyyy HH:mm:ss') AS DataHoraEmissaoNFSe,
    FORMAT(periodos.pgp_dh_criacao,'dd/MM/yyyy HH:mm:ss') AS DataCriacaoPeriodo,
    empresas.emp_ds_cnpj AS EmpresaCNPJ,
    notas.enf_cnpj_tomador AS NFSeCNPJTomador,
    notas.enf_ds_cnpj_emitente AS NFSeCNPJEmitente,
    ISNULL(mot_resp.mot_nm_motorista,'') AS Responsavel,
    dbo.fn_only_numbers(ISNULL(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj)) AS MotoristaCNPJ,
    CASE WHEN mot_resp.mot_ds_empresa_cnpj IS NULL THEN 'Motorista' ELSE 'Responsavel' END AS TipoCNPJ,
    notas.enf_cep_toma AS CEPTomadorNota,
    notas.end_im_toma AS MunicipioTomadorNota,
    empresas.emp_ds_end_cep AS CEPTomador,
    empresas.emp_cd_end_cod_cidade AS MunicipioTomador,
    notas.enf_ds_emit_municipio AS MunicipioEmitente,
    notas.enf_ds_emit_CEP AS CEPEmitente,
    notas.enf_ds_emit_logradouro AS LogradouroEmitente,
    notas.enf_ds_emit_numero AS NumeroEmitente,
    notas.enf_ds_emit_bairro AS BairroEmitente,
    lista_status.lst_ds_valor AS StatusEspelho,

    -- NOVO STATUS
    CASE 
        WHEN notas.enf_ds_resultado = 'An error has occurred.' THEN 'Documento Emitido'
        WHEN notas.enf_ds_resultado = 'Processado com sucesso!' THEN
            CASE
                WHEN v.Valido = 1 THEN 'Documento aprovado'
                WHEN v.Valido IS NULL THEN 'Documento em análise'
                ELSE 'Documento recusado'
            END
        ELSE 'Não processado'
    END AS NovoStatus,

    v.MotivoReprovacao,

    CASE 
        WHEN notas.enf_ds_resultado = 'Processado com sucesso!' THEN
            CASE
                WHEN v.Valido = 1 THEN 37
                WHEN v.Valido IS NULL THEN NULL
                ELSE 36
            END
        ELSE NULL
    END AS CodigoNovoStatus,

    CASE 
        WHEN lista_status.lst_ds_valor = 
            CASE 
                WHEN notas.enf_ds_resultado = 'Processado com sucesso!' THEN
                    CASE
                        WHEN v.Valido = 1 THEN 'Documento aprovado'
                        WHEN v.Valido IS NULL THEN 'Documento em análise'
                        ELSE 'Documento recusado'
                    END
                ELSE 'Não processado'
            END
        THEN 'Igual'
        ELSE 'Diferente'
    END AS Comparacao,

    espelhos.mtn_ds_link_nfs AS Nota,
    notas.enf_ds_chave_nfse AS ChaveNFSe,
    notas.enf_ds_resultado AS ResultadoNFSe,
    mot.mot_cd_matricula AS Matricula,
    CASE 
        WHEN notas.enf_dh_processamento IS NULL THEN 'Não processado'
        WHEN notas.enf_dh_processamento < DATEADD(hour,-3,espelhos.mtn_dh_envio_nfs) THEN 'Pendente atualização'
        ELSE 'Processado'
    END AS StatusProcessamento,
    notas.enf_ds_observacao AS ObservacaoNota,
    notas.enf_nr_nfse AS NumeroNFSe,
    notas.enf_cd_servico AS CodigoServico

FROM tb_pag_espelhos AS espelhos
JOIN tb_pgto_periodo AS periodos ON espelhos.mtn_cd_pgto_periodo = periodos.pgp_cd_periodo
JOIN tb_pag_espelhos_nfse AS notas ON espelhos.mtn_cd_motorista_nfs = notas.enf_cd_espelho
JOIN tb_empresas AS empresas ON espelhos.mtn_cod_cliente = empresas.emp_cd_codigo_cliente AND empresas.emp_integracao_nfse = 1
JOIN tb_usuario users ON espelhos.mtn_cd_motorista = users.usr_cd_usuario
LEFT JOIN tb_usuario users_resp ON users.usr_cd_usr_responsavel_contrato = users_resp.usr_cd_usuario
JOIN tb_motorista mot ON users.usr_cd_usuario = mot.mot_cd_usuario
LEFT JOIN tb_motorista mot_resp ON users_resp.usr_cd_usuario = mot_resp.mot_cd_usuario
JOIN tb_lista AS lista_status ON espelhos.mtn_cd_status = lista_status.lst_cd_lista

CROSS APPLY (
    SELECT
        CASE 
            WHEN p.prm_ds_chave = 'Integração NFSe Habilitada' AND espelhos.mtn_cd_status IS NOT NULL THEN 1
            WHEN p.prm_ds_chave IN ('Integração NFSe valor tolerância (+)','Integração NFSe valor tolerância (-)')
                 AND ABS(CAST(ISNULL(espelhos.mtn_vl_nfs,0) AS FLOAT) - CAST(ISNULL(notas.enf_vl_nota,0) AS FLOAT)) 
                     <= CAST(ISNULL(TRY_CAST(p.prm_ds_valor AS DECIMAL(9,2)),0) AS DECIMAL(9,2)) THEN 1
            WHEN p.prm_ds_chave <> 'Integração NFSe valor tolerância (+)' 
                 AND p.prm_ds_chave <> 'Integração NFSe valor tolerância (-)'
                 AND p.prm_ds_valor = 'true'
                 AND (
                     (p.prm_ds_chave = 'Verifica se a data emissão da nota foi feita depois da criação do espelho' AND notas.enf_dh_emissao >= espelhos.mtn_dh_criacao) OR
                     (p.prm_ds_chave = 'Verifica se o cep do tomador esta conforme o cadastrado' AND notas.enf_cep_toma = empresas.emp_ds_end_cep) OR
                     (p.prm_ds_chave = 'Verifica se o cnpj do emitente esta conforme cadastrado' AND dbo.fn_only_numbers(notas.enf_ds_cnpj_emitente) = dbo.fn_only_numbers(ISNULL(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj))) OR
                     (p.prm_ds_chave = 'Verifica se o cnpj do tomador esta conforme cadastrado' AND notas.enf_cnpj_tomador = empresas.emp_ds_cnpj) OR
                     (p.prm_ds_chave = 'Verifica se o código de serviço esta correto' AND notas.enf_cd_servico IN (160201,260101)) OR
                     (p.prm_ds_chave = 'Verifica se o documento do emitente é um cnpj' AND LEN(notas.enf_ds_cnpj_emitente) = 14)
                 ) THEN 1
            ELSE 0
        END AS Valido,

        CASE
            WHEN p.prm_ds_chave IN ('Integração NFSe valor tolerância (+)','Integração NFSe valor tolerância (-)')
                 AND ABS(CAST(ISNULL(espelhos.mtn_vl_nfs,0) AS FLOAT) - CAST(ISNULL(notas.enf_vl_nota,0) AS FLOAT)) 
                     > CAST(ISNULL(TRY_CAST(p.prm_ds_valor AS DECIMAL(9,2)),0) AS DECIMAL(9,2)) THEN 'Valor da nota divergente'
            WHEN p.prm_ds_chave = 'Verifica se a data emissão da nota foi feita depois da criação do espelho'
                 AND p.prm_ds_valor = 'true' AND notas.enf_dh_emissao < espelhos.mtn_dh_criacao THEN 'Data emissão anterior ao espelho'
            WHEN p.prm_ds_chave = 'Verifica se o cep do tomador esta conforme o cadastrado'
                 AND p.prm_ds_valor = 'true' AND notas.enf_cep_toma <> empresas.emp_ds_end_cep THEN 'CEP do tomador incorreto'
            WHEN p.prm_ds_chave = 'Verifica se o cnpj do emitente esta conforme cadastrado'
                 AND p.prm_ds_valor = 'true' AND dbo.fn_only_numbers(notas.enf_ds_cnpj_emitente) <> dbo.fn_only_numbers(ISNULL(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj)) THEN 'CNPJ do emitente incorreto'
            WHEN p.prm_ds_chave = 'Verifica se o cnpj do tomador esta conforme cadastrado'
                 AND p.prm_ds_valor = 'true' AND notas.enf_cnpj_tomador <> empresas.emp_ds_cnpj THEN 'CNPJ do tomador incorreto'
            WHEN p.prm_ds_chave = 'Verifica se o código de serviço esta correto'
                 AND p.prm_ds_valor = 'true' AND notas.enf_cd_servico NOT IN (160201,260101) THEN 'Código de serviço inválido'
            WHEN p.prm_ds_chave = 'Verifica se o documento do emitente é um cnpj'
                 AND p.prm_ds_valor = 'true' AND LEN(notas.enf_ds_cnpj_emitente) <> 14 THEN 'Documento emitente inválido'
            ELSE NULL
        END AS MotivoReprovacao
    FROM tb_parametros p
    WHERE p.prm_ds_categoria = 'Validação de NFSE'
      AND p.prm_cod_cliente = espelhos.mtn_cod_cliente
) v

WHERE espelhos.mtn_cod_cliente IN (27,37,45,61)
  AND espelhos.mtn_dh_criacao >= '2025-03-27';
GO
