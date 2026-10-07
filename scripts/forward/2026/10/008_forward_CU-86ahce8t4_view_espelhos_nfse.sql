/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahce8t4
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Parametriza as mensagens de reprovação de NFSe por cliente:
                 MotivoReprovacao passa a resolver COALESCE(override por cliente
                 -> catálogo global -> texto fixo original), e erros de
                 integração passam pelo catálogo casado por mtr_ds_descricao
                 (= texto exato do enf_ds_resultado). Nenhuma validação nova é
                 adicionada — conjunto de regras idêntico à versão vigente.
  Rollback     : scripts/rollback/2026/10/008_rollback_CU-86ahce8t4_view_espelhos_nfse.sql
  Objetos      : dbo.vw_espelhos_nfse
  Dependências : dbo.tb_pag_nfse_motivo_reprovacao,
                 dbo.tb_pag_nfse_mensagem_cliente (scripts 005/006)
                 Consumidores: UspAtualizaStatusNFSe (script 009),
                 sp_integrar_pagamentos_oxpay, sp_integrar_pagamentos_oxpay_tmp
  ==============================================================================*/

SET NOCOUNT ON;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[vw_espelhos_nfse] AS

select
notas.enf_ds_resultado,
espelhos.mtn_cd_motorista_nfs as CodigoEspelho,
       espelhos.mtn_nome_motorista as Motorista,
       espelhos.mtn_cod_cliente as CodigoCliente,
       espelhos.mtn_cd_pgto_periodo as CodigoPeriodo,
       cast(espelhos.mtn_vl_nfs as float) as ValorEspelho,
       cast(notas.enf_vl_nota as float) as ValorNota,
       format(espelhos.mtn_dh_criacao,'dd/MM/yyyy HH:mm:ss') as DataHoraEspelho,
       format(notas.enf_dh_emissao,'dd/MM/yyyy HH:mm:ss') as DataHoraEmissaoNFSe,
       format(periodos.pgp_dh_criacao,'dd/MM/yyyy HH:mm:ss') as DataCriacaoPeriodo,
       empresas.emp_ds_cnpj as EmpresaCNPJ,
       notas.enf_cnpj_tomador as NFSeCNPJTomador,
       notas.enf_ds_cnpj_emitente as NFSeCNPJEmitente,
       isnull(mot_resp.mot_nm_motorista,'') as Responsavel,
       dbo.fn_only_numbers(isnull(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj)) as MotoristaCNPJ,
       case when mot_resp.mot_ds_empresa_cnpj is null then 'Motorista' else 'Responsavel' end as TipoCNPJ,
       notas.enf_cep_toma as CEPTomadorNota,
       notas.end_im_toma as MunicipioTomadorNota,
       empresas.emp_ds_end_cep as CEPTomador,
       empresas.emp_cd_end_cod_cidade as MunicipioTomador,

       notas.enf_ds_emit_municipio as MunicipioEmitente,
       notas.enf_ds_emit_CEP as CEPEmitente,
       notas.enf_ds_emit_logradouro as LogradouroEmitente,
       notas.enf_ds_emit_numero as NumeroEmitente,
       notas.enf_ds_emit_bairro as BairroEmitente,
       lista_status.lst_ds_valor as StatusEspelho,


    case
    when notas.enf_ds_resultado not in ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA')
        then 'Documento recusado'
    else
        case
            when notas.enf_ds_resultado in ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA') then
                case
                    when
                        (
                            VldValores.prm_ds_valor = 'false'
                            OR
                            (
                                VldValores.prm_ds_valor = 'true'
                                AND espelhos.mtn_vl_nfs BETWEEN
                                    (notas.enf_vl_nota - CAST(ISNULL(valor_tolerancia_negativo.prm_ds_valor,0) AS DECIMAL(9,2)))
                                    AND
                                    (notas.enf_vl_nota + CAST(ISNULL(valor_tolerancia_positivo.prm_ds_valor,0) AS DECIMAL(9,2)))
                            )
                        )
                        AND (
                            DataEmissao.prm_ds_valor = 'false'
                            OR (DataEmissao.prm_ds_valor = 'true' AND CAST(notas.enf_dh_emissao AS DATE) >= CAST(espelhos.mtn_dh_criacao AS DATE))
                        )
                        AND (
                            CNPJTomador.prm_ds_valor = 'false'
                            OR (CNPJTomador.prm_ds_valor = 'true' AND ISNULL(empresas.emp_ds_cnpj,'-') = ISNULL(notas.enf_cnpj_tomador,''))
                        )
                        AND (
                            CEP.prm_ds_valor = 'false'
                            OR (CEP.prm_ds_valor = 'true' AND replace(empresas.emp_ds_end_cep,'-','') = replace(notas.enf_cep_toma,'-',''))
                        )
                        AND (
                            cnpjEmitente.prm_ds_valor = 'false'
                            OR (cnpjEmitente.prm_ds_valor = 'true' AND LEN(notas.enf_ds_cnpj_emitente) = 14 AND ISNULL(notas.enf_ds_cnpj_emitente,'0') <> '0')
                        )
                        and (
                            cnpjDsEmitente.prm_ds_valor = 'false'
                            OR (cnpjDsEmitente.prm_ds_valor = 'true' AND ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj) = notas.enf_ds_cnpj_emitente)
                        )
                        AND (
                            CodServico.prm_ds_valor = 'false'
                            OR (
                                CodServico.prm_ds_valor = 'true'
                                AND replace(enf_cd_servico,'.','') IN (
                                    SELECT CAST(value AS INT)
                                    FROM STRING_SPLIT(ListCodServico.prm_ds_valor, ',')
                                )
                            )
                        )
                    then 'Documento aprovado'
                    else
                        case
                            when (dbo.fn_only_numbers(notas.enf_ds_cnpj_emitente) <> dbo.fn_only_numbers(isnull(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj)) and espelhos.mtn_cod_cliente = 27)
                                then 'Documento em análise'
                            else 'Documento recusado'
                        end
                end
            else 'Não processado'
        end
end as NovoStatus,


        -- MOTIVO DE REPROVAÇÃO (mensagens parametrizáveis)
    CASE
    WHEN notas.enf_ds_resultado NOT IN ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA')
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov_res.msg)),''), mtr_res.msg, notas.enf_ds_resultado)
    WHEN VldValores.prm_ds_valor = 'true'
         AND NOT (
             espelhos.mtn_vl_nfs BETWEEN
                 (notas.enf_vl_nota - CAST(ISNULL(valor_tolerancia_negativo.prm_ds_valor,0) AS DECIMAL(9,2)))
                 AND
                 (notas.enf_vl_nota + CAST(ISNULL(valor_tolerancia_positivo.prm_ds_valor,0) AS DECIMAL(9,2)))
         )
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_valor_tolerancia)),''), cat.msg_valor_tolerancia, 'Recusado: valor do espelho está fora da tolerância permitida.')
    WHEN DataEmissao.prm_ds_valor = 'true'
         AND CAST(notas.enf_dh_emissao AS DATE) < CAST(espelhos.mtn_dh_criacao AS DATE)
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_data_emissao)),''), cat.msg_data_emissao, 'Recusado: data de emissão da NFSe não corresponde ao período de pagamento.')
    WHEN CNPJTomador.prm_ds_valor = 'true'
         AND ISNULL(empresas.emp_ds_cnpj,'-') <> ISNULL(notas.enf_cnpj_tomador,'')
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_cnpj_tomador)),''), cat.msg_cnpj_tomador, 'Recusado: CNPJ do tomador da NFSe não confere com o cadastro da empresa.')
    WHEN CEP.prm_ds_valor = 'true'
         AND replace(empresas.emp_ds_end_cep,'-','') <> replace(notas.enf_cep_toma,'-','')
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_cep)),''), cat.msg_cep, 'Recusado: CEP informado na NFSe não corresponde ao cadastro da empresa.')
    WHEN cnpjEmitente.prm_ds_valor = 'true'
         AND (LEN(notas.enf_ds_cnpj_emitente) <> 14 OR ISNULL(notas.enf_ds_cnpj_emitente,'0') = '0')
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_cnpj_emit_formato)),''), cat.msg_cnpj_emit_formato, 'Recusado: CNPJ do emitente da NFSe inválido ou em formato incorreto.')
    WHEN cnpjDsEmitente.prm_ds_valor = 'true'
         AND (
             dbo.fn_only_numbers(ISNULL(notas.enf_ds_cnpj_emitente, 0))
             <> dbo.fn_only_numbers(ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj))
             OR dbo.fn_only_numbers(ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj)) is null
             OR ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj) <> notas.enf_ds_cnpj_emitente
             OR ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj) is null
         )
            THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_cnpj_emit_cadastro)),''), cat.msg_cnpj_emit_cadastro, 'Recusado: CNPJ do emitente da NFSe é divergente do cadastro do motorista')
    WHEN CodServico.prm_ds_valor = 'true'
         AND replace(enf_cd_servico,'.','') NOT IN (
             SELECT CAST(value AS INT)
             FROM STRING_SPLIT(ListCodServico.prm_ds_valor, ',')
         )
        THEN COALESCE(NULLIF(LTRIM(RTRIM(ov.msg_cod_servico)),''), cat.msg_cod_servico, 'Recusado: código de serviço da NFSe não está na lista permitida.')
    ELSE ''
END as MotivoReprovacao,


        -- CÓDIGO NOVO STATUS
    case
    when notas.enf_ds_resultado not in ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA')
        then 36
    else
        case
            when notas.enf_ds_resultado in ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA') then
                case
                    when
                        (
                            VldValores.prm_ds_valor = 'false'
                            OR
                            (
                                VldValores.prm_ds_valor = 'true'
                                AND espelhos.mtn_vl_nfs BETWEEN
                                    (notas.enf_vl_nota - CAST(ISNULL(valor_tolerancia_negativo.prm_ds_valor,0) AS DECIMAL(9,2)))
                                    AND
                                    (notas.enf_vl_nota + CAST(ISNULL(valor_tolerancia_positivo.prm_ds_valor,0) AS DECIMAL(9,2)))
                            )
                        )
                        AND (
                            DataEmissao.prm_ds_valor = 'false'
                            OR (DataEmissao.prm_ds_valor = 'true' AND CAST(notas.enf_dh_emissao AS DATE) >= CAST(espelhos.mtn_dh_criacao AS DATE))
                        )
                        AND (
                            CNPJTomador.prm_ds_valor = 'false'
                            OR (CNPJTomador.prm_ds_valor = 'true' AND ISNULL(empresas.emp_ds_cnpj,'-') = ISNULL(notas.enf_cnpj_tomador,''))
                        )
                        AND (
                            CEP.prm_ds_valor = 'false'
                            OR (CEP.prm_ds_valor = 'true' AND replace(empresas.emp_ds_end_cep,'-','') = replace(notas.enf_cep_toma,'-',''))
                        )
                        AND (
                            cnpjEmitente.prm_ds_valor = 'false'
                            OR (cnpjEmitente.prm_ds_valor = 'true' AND LEN(notas.enf_ds_cnpj_emitente) = 14 AND ISNULL(notas.enf_ds_cnpj_emitente,'0') <> '0')
                        )
                        and (
                            cnpjDsEmitente.prm_ds_valor = 'false'
                            OR (cnpjDsEmitente.prm_ds_valor = 'true' AND ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj) = notas.enf_ds_cnpj_emitente)
                        )
                        AND (
                            CodServico.prm_ds_valor = 'false'
                            OR (
                                CodServico.prm_ds_valor = 'true'
                                AND replace(enf_cd_servico,'.','') IN (
                                    SELECT CAST(value AS INT)
                                    FROM STRING_SPLIT(ListCodServico.prm_ds_valor, ',')
                                )
                            )
                        )
                    then 37
                    else 36
                end
            else 36
        end
end as CodigoNovoStatus,

        -- COMPARAÇÃO
    case
    when lista_status.lst_ds_valor =
        case
            when notas.enf_ds_resultado in ('Nota Fiscal Integrada Via Governo','Nota fiscal validada com sucesso via IA') then
                case
                    when
                        (
                            VldValores.prm_ds_valor = 'false'
                            OR
                            (
                                VldValores.prm_ds_valor = 'true'
                                AND espelhos.mtn_vl_nfs BETWEEN
                                    (notas.enf_vl_nota - CAST(ISNULL(valor_tolerancia_negativo.prm_ds_valor,0) AS DECIMAL(9,2)))
                                    AND
                                    (notas.enf_vl_nota + CAST(ISNULL(valor_tolerancia_positivo.prm_ds_valor,0) AS DECIMAL(9,2)))
                            )
                        )
                        AND (
                            DataEmissao.prm_ds_valor = 'false'
                            OR (DataEmissao.prm_ds_valor = 'true' AND CAST(notas.enf_dh_emissao AS DATE) >= CAST(espelhos.mtn_dh_criacao AS DATE))
                        )
                        AND (
                            CNPJTomador.prm_ds_valor = 'false'
                   OR (CNPJTomador.prm_ds_valor = 'true' AND ISNULL(empresas.emp_ds_cnpj,'-') = ISNULL(notas.enf_cnpj_tomador,''))
                      )
                        AND (
                            CEP.prm_ds_valor = 'false'
                            OR (CEP.prm_ds_valor = 'true' AND replace(empresas.emp_ds_end_cep,'-','') = replace(notas.enf_cep_toma,'-',''))
                        )
                        AND (
                            cnpjEmitente.prm_ds_valor = 'false'
                            OR (cnpjEmitente.prm_ds_valor = 'true' AND LEN(notas.enf_ds_cnpj_emitente) = 14 AND ISNULL(notas.enf_ds_cnpj_emitente,'0') <> '0')
                        )
                        and (
                            cnpjDsEmitente.prm_ds_valor = 'false'
                            OR (cnpjDsEmitente.prm_ds_valor = 'true' AND ISNULL(mot_resp.mot_ds_empresa_cnpj, mot.mot_ds_empresa_cnpj) = notas.enf_ds_cnpj_emitente)
                        )
                        AND (
                            CodServico.prm_ds_valor = 'false'
                            OR (
                                CodServico.prm_ds_valor = 'true'
                                AND replace(enf_cd_servico,'.','') IN (
                                    SELECT CAST(value AS INT)
                                    FROM STRING_SPLIT(ListCodServico.prm_ds_valor, ',')
                                )
                            )
                        )
                    then 'Documento aprovado'
                    else
                        case
                            when (dbo.fn_only_numbers(notas.enf_ds_cnpj_emitente) <> dbo.fn_only_numbers(isnull(mot_resp.mot_ds_empresa_cnpj,mot.mot_ds_empresa_cnpj)) and espelhos.mtn_cod_cliente = 27)
                                then 'Documento em análise'
                            else 'Documento recusado'
                        end
                end
            else 'Não processado'
        end
    then 'Igual'
    else 'Diferente'
end as Comparacao,
        espelhos.mtn_ds_link_nfs as Nota,
        notas.enf_ds_chave_nfse as ChaveNFSe,
        notas.enf_ds_resultado as ResultadoNFSe,
        mot.mot_cd_matricula as Matricula,
        case when notas.enf_dh_processamento is null then 'Não processado'
             when notas.enf_dh_processamento < dateadd(hour,-3,espelhos.mtn_dh_envio_nfs) then 'Pendente atualização'
             else 'Processado'
        end as StatusProcessamento,
        notas.enf_ds_observacao ObservacaoNota,
        lista_status_int.lst_ds_valor as StatusIntegracao,
        mot.mot_ds_empresa_cnpj,
        notas.enf_ds_cnpj_emitente


    from tb_pag_espelhos as espelhos with(nolock)
    join tb_parametros as parametros
    on espelhos.mtn_cod_cliente = parametros.prm_cod_cliente
    and parametros.prm_ds_chave = 'Integração NFSe Habilitada'
    and parametros.prm_ds_categoria = 'Validação de NFSE'
    and parametros.prm_ds_valor = 'true'

    left join tb_parametros as valor_tolerancia_positivo
    on espelhos.mtn_cod_cliente = valor_tolerancia_positivo.prm_cod_cliente
    and valor_tolerancia_positivo.prm_ds_chave = 'Integração NFSe valor tolerância (+)'
    and valor_tolerancia_positivo.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as valor_tolerancia_negativo
    on espelhos.mtn_cod_cliente = valor_tolerancia_negativo.prm_cod_cliente
    and valor_tolerancia_negativo.prm_ds_chave = 'Integração NFSe valor tolerância (-)'
    and valor_tolerancia_negativo.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as DataEmissao
    on espelhos.mtn_cod_cliente = DataEmissao.prm_cod_cliente
    and DataEmissao.prm_ds_chave = 'Data de Emissão'
    and DataEmissao.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as CNPJTomador
    on espelhos.mtn_cod_cliente = CNPJTomador.prm_cod_cliente
    and CNPJTomador.prm_ds_chave = 'CNPJ Tomador'
    and CNPJTomador.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as CEP
    on espelhos.mtn_cod_cliente = CEP.prm_cod_cliente
    and CEP.prm_ds_chave = 'CEP'
    and CEP.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as cnpjEmitente
    on espelhos.mtn_cod_cliente = cnpjEmitente.prm_cod_cliente
    and cnpjEmitente.prm_ds_chave = 'CNPJ Emitente (Formato)'
    and cnpjEmitente.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as ListCodServico
    on espelhos.mtn_cod_cliente = ListCodServico.prm_cod_cliente
    and ListCodServico.prm_ds_chave = 'Lista do Código de serviço'
    and ListCodServico.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as CodServico
    on espelhos.mtn_cod_cliente = CodServico.prm_cod_cliente
    and CodServico.prm_ds_chave = 'Código de Serviço'
    and CodServico.prm_ds_categoria = 'Validação de NFSE'

    left join tb_parametros as cnpjDsEmitente
    on espelhos.mtn_cod_cliente = cnpjDsEmitente.prm_cod_cliente
    and cnpjDsEmitente.prm_ds_chave = 'CNPJ Emitente (Cadastro)'
    and cnpjDsEmitente.prm_ds_categoria = 'Validação de NFSE'

    join tb_pgto_periodo as periodos on espelhos.mtn_cd_pgto_periodo = periodos.pgp_cd_periodo
    join tb_pag_espelhos_nfse as notas with(nolock)
    on espelhos.mtn_cd_motorista_nfs = notas.enf_cd_espelho
        left join tb_empresas as empresas
    on espelhos.mtn_cod_cliente = empresas.emp_cd_codigo_cliente
    and empresas.emp_integracao_nfse = 1
    and emp_ds_cnpj = enf_cnpj_tomador

    join tb_usuario users on espelhos.mtn_cd_motorista = users.usr_cd_usuario
    left join tb_usuario users_resp on users.usr_cd_usr_responsavel_contrato = users_resp.usr_cd_usuario
    join tb_motorista mot on users.usr_cd_usuario = mot.mot_cd_usuario
    left join tb_motorista mot_resp on users_resp.usr_cd_usuario = mot_resp.mot_cd_usuario
    join tb_lista as lista_status on espelhos.mtn_cd_status = lista_status.lst_cd_lista
    left join tb_lista as lista_status_int on notas.enf_status_integracao = lista_status_int.lst_cd_lista

    left join tb_parametros as VldValores
on espelhos.mtn_cod_cliente = VldValores.prm_cod_cliente
and VldValores.prm_ds_chave = 'Valores'
and VldValores.prm_ds_categoria = 'Validação de NFSE'

	cross join (
		select
			max(case when mtr_ds_chave = 'VALOR_TOLERANCIA'       then mtr_ds_mensagem_padrao end) as msg_valor_tolerancia,
			max(case when mtr_ds_chave = 'DATA_EMISSAO'           then mtr_ds_mensagem_padrao end) as msg_data_emissao,
			max(case when mtr_ds_chave = 'CNPJ_TOMADOR'           then mtr_ds_mensagem_padrao end) as msg_cnpj_tomador,
			max(case when mtr_ds_chave = 'CEP'                    then mtr_ds_mensagem_padrao end) as msg_cep,
			max(case when mtr_ds_chave = 'CNPJ_EMITENTE_FORMATO'  then mtr_ds_mensagem_padrao end) as msg_cnpj_emit_formato,
			max(case when mtr_ds_chave = 'CNPJ_EMITENTE_CADASTRO' then mtr_ds_mensagem_padrao end) as msg_cnpj_emit_cadastro,
			max(case when mtr_ds_chave = 'COD_SERVICO'            then mtr_ds_mensagem_padrao end) as msg_cod_servico
		from dbo.tb_pag_nfse_motivo_reprovacao with(nolock)
		where mtr_in_ativo = 1
	) cat

	left join (
		select o.mnc_cod_cliente,
			max(case when m.mtr_ds_chave = 'VALOR_TOLERANCIA'       then o.mnc_ds_mensagem end) as msg_valor_tolerancia,
			max(case when m.mtr_ds_chave = 'DATA_EMISSAO'           then o.mnc_ds_mensagem end) as msg_data_emissao,
			max(case when m.mtr_ds_chave = 'CNPJ_TOMADOR'           then o.mnc_ds_mensagem end) as msg_cnpj_tomador,
			max(case when m.mtr_ds_chave = 'CEP'                    then o.mnc_ds_mensagem end) as msg_cep,
			max(case when m.mtr_ds_chave = 'CNPJ_EMITENTE_FORMATO'  then o.mnc_ds_mensagem end) as msg_cnpj_emit_formato,
			max(case when m.mtr_ds_chave = 'CNPJ_EMITENTE_CADASTRO' then o.mnc_ds_mensagem end) as msg_cnpj_emit_cadastro,
			max(case when m.mtr_ds_chave = 'COD_SERVICO'            then o.mnc_ds_mensagem end) as msg_cod_servico
		from dbo.tb_pag_nfse_mensagem_cliente o with(nolock)
		join dbo.tb_pag_nfse_motivo_reprovacao m with(nolock)
			on m.mtr_cd_motivo = o.mnc_cd_motivo
		where o.mnc_in_ativo = 1
		  and o.mnc_in_excluido = 0
		group by o.mnc_cod_cliente
	) ov on ov.mnc_cod_cliente = espelhos.mtn_cod_cliente

	-- Erros de integracao: catalogo casado pelo texto exato do
	-- enf_ds_resultado (em mtr_ds_descricao). Agregado -> nao multiplica linhas.
	left join (
		select mtr_ds_descricao,
			   min(mtr_cd_motivo) as cd_motivo,
			   max(mtr_ds_mensagem_padrao) as msg
		from dbo.tb_pag_nfse_motivo_reprovacao with(nolock)
		where mtr_in_ativo = 1
		group by mtr_ds_descricao
	) mtr_res on mtr_res.mtr_ds_descricao = notas.enf_ds_resultado

	-- Override por cliente para os erros de integracao.
	left join (
		select mnc_cod_cliente, mnc_cd_motivo, max(mnc_ds_mensagem) as msg
		from dbo.tb_pag_nfse_mensagem_cliente with(nolock)
		where mnc_in_ativo = 1 and mnc_in_excluido = 0
		group by mnc_cod_cliente, mnc_cd_motivo
	) ov_res on ov_res.mnc_cod_cliente = espelhos.mtn_cod_cliente
			and ov_res.mnc_cd_motivo = mtr_res.cd_motivo

where 1=1
      and espelhos.mtn_dh_criacao >= '2025-12-01'
GO

PRINT 'SUCESSO: vw_espelhos_nfse alterada (mensagens parametrizáveis por cliente).';
GO
