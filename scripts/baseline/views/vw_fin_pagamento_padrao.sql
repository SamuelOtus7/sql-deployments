-- ============================================================
-- BASELINE: dbo.vw_fin_pagamento_padrao
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_pagamento_padrao]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_fin_pagamento_padrao] as

SELECT  
    notas.mtn_cod_cliente,
    notas.mtn_cd_motorista_nfs as Id, 
    usuario.usr_nm_usuario as Nome, 
    usuario.usr_cd_usuario CodDriver, 
    periodo.pgp_nm_periodo as Periodo, 
    listaEspelho.lst_ds_valor as TipoEspelho, 
    notas.mtn_cd_status as CodStatus, 
    lista.lst_ds_valor as Status, 
    notas.mtn_vl_nfs as Valor, 
    notas.mtn_qt_rotas as Rotas, 
    notas.mtn_ds_link_nfs as LinkNfs, 
    notas.mtn_ds_linkespelho as LinkEspelho, 
    notas.mtn_dt_prazo_contestacao as PrazoContestacao,
    notas.mtn_cd_tipo_espelho, 
    notas.mtn_cd_cliente_transportadora, 
    notas.mtn_cd_base, 
    notas.mtn_cd_pgto_periodo as CodPeriodo, 
    notas.mtn_cd_motorista_nfs as CodPagEspelho 

FROM tb_pag_espelhos as notas 
INNER JOIN tb_usuario as usuario with(nolock) 
ON notas.mtn_cd_motorista = usuario.usr_cd_usuario 
INNER JOIN tb_pgto_periodo as periodo 
ON notas.mtn_cd_pgto_periodo = periodo.pgp_cd_periodo 
INNER join tb_lista as lista 
ON notas.mtn_cd_status = lista.lst_cd_lista 
LEFT join tb_lista as listaEspelho 
ON notas.mtn_cd_tipo_espelho = listaEspelho.lst_cd_lista 
-- WHERE 
--     (@Admin = 1 or notas.mtn_cod_cliente = @CodCliente) 
WHERE mtn_in_excluido = 0
GO
