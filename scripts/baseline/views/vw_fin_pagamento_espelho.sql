-- ============================================================
-- BASELINE: dbo.vw_fin_pagamento_espelho
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_pagamento_espelho]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_fin_pagamento_espelho] as

SELECT 
    notas.mtn_cd_motorista_nfs as Id,    
    notas.mtn_cod_cliente,
    usuario.usr_nm_usuario as Nome,
    usuario.usr_cd_usuario as CodDriver,
    periodo.pgp_nm_periodo as Periodo,
    listaEspelho.lst_ds_valor as TipoEspelho,
    notas.mtn_cd_status as CodStatus,
    lista.lst_ds_valor as Status,
    notas.mtn_dh_envio_nfs as DataHoraEnvioNF,
    notas.mtn_dh_envio_nfs_secundario as DataHoraEnvioNFSecundario,
    notas.mtn_vl_nfs as Valor,
    notas.mtn_vl_imposto as Impostos,
    notas.mtn_vl_liquido as ValorLiquido,
    notas.mtn_qt_rotas as Rotas,
    notas.mtn_ds_link_nfs as LinkNfs,
    notas.mtn_ds_link_nfs_secundario as LinkNfsSecundario,
    notas.mtn_ds_linkespelho as LinkEspelho,
    notas.mtn_dt_prazo_contestacao as PrazoContestacao,
    notas.mtn_cd_tipo_espelho,
    notas.mtn_cd_cliente_transportadora,
    notas.mtn_cd_base,
    notas.mtn_cd_pgto_periodo as CodPeriodo,
    notas.mtn_cd_motorista_nfs as CodPagEspelho,
    motoristas.mot_cd_matricula as Matricula,
    motoristas.mot_pag_nm_empresa,
    motoristas.mot_pag_nm_banco,
    motoristas.mot_pag_cpf_titular,
    motoristas.mot_pag_cnpj_titular,
    motoristas.mot_pag_cd_agencia,
    motoristas.mot_pag_cd_conta,
    motoristas.mot_pag_ds_tipo_conta,
    motoristas.mot_pag_nm_titular,
    motoristas.mot_ds_pix_key_type,
    motoristas.mot_ds_pix_key,
    motoristas.mot_cnt_emg_vl_telefone,
    motoristas.mot_cnt_vl_email,
    motoristas.mot_cd_numero_cartao,
    historico.lsm_ds_mensagem,
    listaBancos.lst_ds_label as NomeBanco,
    listaTipoPix.lst_ds_label as TipoPix,
    ISNULL(responsavelContrato.usr_nm_usuario, usuario.usr_nm_usuario) as NomeResponsavelContrato,
    tiposContratos.ttc_nm_tipo as TipoContrato,
    CASE
        WHEN listaTipoPagamento.lst_ds_label = 'CIOT' AND EXISTS (
            SELECT 1
            FROM tb_trg_CIOT
            WHERE CPFMotorista = motoristas.mot_cpf
              AND StatusProcesso = 21
              AND CONVERT(date, DataHoraInicio) >= CONVERT(date, periodo.pgp_dt_inicio)
              AND CONVERT(date, DataHoraInicio) <= CONVERT(date, periodo.pgp_dt_fim)
        )
        THEN 'CIOT Declarado'
        ELSE listaTipoPagamento.lst_ds_label
    END as TipoPagamento,
    periodo.pgp_dt_inicio as data_inicio,
    periodo.pgp_dt_fim as data_fim,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM tb_pag_espelhos_logs as st_log
            JOIN tb_lista as lista_log ON st_log.lsm_cd_status_atual = lista_log.lst_cd_lista
            WHERE st_log.lsm_cd_motorista_nfs = notas.mtn_cd_motorista_nfs
              AND lista_log.lst_ds_valor = 'Solicitado Reanálise'
        ) THEN 'Sim'
        ELSE 'Não'
    END as PossuiLogReanalise,
	case 
		when mtn_cd_motorista is null 
			then 'Sem Cadastro' 
		when usuario.usr_in_ativo = 0
			then 'Cadastro Inativo'
		else 'Cadastrado' end SituacaoCadastro

FROM tb_pag_espelhos as notas
left JOIN tb_usuario as usuario WITH (NOLOCK)
    ON notas.mtn_cd_motorista = usuario.usr_cd_usuario
INNER JOIN tb_pgto_periodo as periodo
    ON notas.mtn_cd_pgto_periodo = periodo.pgp_cd_periodo
INNER JOIN tb_lista as lista
    ON notas.mtn_cd_status = lista.lst_cd_lista
LEFT JOIN tb_lista as listaEspelho
    ON notas.mtn_cd_tipo_espelho = listaEspelho.lst_cd_lista
left JOIN tb_motorista as motoristas
    ON usuario.usr_cd_usuario = motoristas.mot_cd_usuario
LEFT JOIN tb_lista as listaBancos
    ON motoristas.mot_cd_banco = listaBancos.lst_cd_lista
LEFT JOIN tb_lista as listaTipoPix
    ON motoristas.mot_ds_pix_key_type = listaTipoPix.lst_ds_valor AND listaTipoPix.lst_nm_lista = 'Tipo Chave Pix'
LEFT JOIN tb_lista as listaTipoPagamento
    ON motoristas.mot_pag_cd_tipo_pagamento = listaTipoPagamento.lst_ds_chave AND listaTipoPagamento.lst_nm_lista = 'Tipo de Pagamento'
LEFT JOIN tb_usuario as usuarioResponsavel
    ON motoristas.mot_cd_usuario = usuarioResponsavel.usr_cd_usuario
LEFT JOIN tb_usuario as responsavelContrato
    ON usuarioResponsavel.usr_cd_usr_responsavel_contrato = responsavelContrato.usr_cd_usuario
LEFT JOIN tb_tipo_contrato as tiposContratos
    ON tiposContratos.ttc_cd_tipo_contrato = motoristas.mot_ctn_cd_tipo_contrato
OUTER APPLY (
    SELECT TOP 1
        tpel.lsm_ds_mensagem
    FROM tb_pag_espelhos_logs tpel
    WHERE tpel.lsm_cd_motorista_nfs = notas.mtn_cd_motorista_nfs
    ORDER BY tpel.lsm_dt_data_log DESC
) historico



GO
