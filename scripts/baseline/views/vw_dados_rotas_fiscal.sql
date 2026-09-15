-- ============================================================
-- BASELINE: dbo.vw_dados_rotas_fiscal
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dados_rotas_fiscal]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vw_dados_rotas_fiscal]
as
select
	c.cli_cd_codigo_cliente TenantId
	,'Shopee' as Marketplace
	,r.TipoOperacao
	,r.CodigoRota
	,r.DataReferencia
	,r.Motorista MotoristaRota
	,mot_cd_motorista IdMotorista
	,mot_nm_motorista NomeMotorista
	,v.vei_cd_veiculo CodigoVeiculo
	,CASE WHEN CHARINDEX(',', r.placa) > 0 THEN LEFT(r.placa, CHARINDEX(',', placa) - 1) ELSE placa end Placa
	,v2.vei_cd_veiculo CodigoVeiculoReboque
	,CASE WHEN CHARINDEX(',', r.placa) > 0 THEN SUBSTRING(r.placa,CHARINDEX(',', placa) + 1,LEN(placa)) ELSE NULL END Reboque
	,b.bss_cd_base CodigoBaseExpedidor
	,b.bss_ds_cpf_cnpj CnpjBaseExpedidor
	,p.IdParticipante IdParticipanteExpedidor
	,r.StationOrigem BaseExpedidor
	,b2.bss_cd_base CodigoBaseRecebedor
	,b2.bss_ds_cpf_cnpj CnpjBaseRecebedor
	,p2.IdParticipante IdParticipanteRecebedor
	,r.StationDestino BaseRecebedor
from
	tb_spe_rotas_v5 r with(nolock)
	join tb_clientes c with(nolock) on r.IdTransportadora = c.cli_id_shopee
	left join tb_usuario u with(nolock) on r.UsuarioIrisys = u.usr_cd_usuario
	left join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
														and u.cli_cd_codigo_cliente = m.mot_cd_cliente
	left join tb_veiculos v with(nolock) on CASE WHEN CHARINDEX(',', placa) > 0 THEN LEFT(placa, CHARINDEX(',', placa) - 1) ELSE placa end = v.vei_ds_placa
														and v.vei_in_excluido = 0
														and c.cli_cd_codigo_cliente = v.vei_cd_cliente
	left join tb_veiculos v2 with(nolock) on CASE WHEN CHARINDEX(',', r.placa) > 0 THEN SUBSTRING(r.placa,CHARINDEX(',', placa) + 1,LEN(placa)) ELSE NULL END = v2.vei_ds_placa
														and v2.vei_in_excluido = 0
														and c.cli_cd_codigo_cliente = v2.vei_cd_cliente
	left join tb_bases b with(nolock) on (r.StationOrigem = b.bss_ds_sigla or r.StationOrigem = b.bss_ds_nome)
								and r.IdTransportadora = b.bss_cd_idtransportadora
	left join tb_bases b2 with(nolock) on (r.StationDestino = b2.bss_ds_sigla or r.StationDestino = b2.bss_ds_nome)
								and r.IdTransportadora = b2.bss_cd_idtransportadora
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_participantes p with(nolock) on b.bss_ds_cpf_cnpj = p.CnpjCpf 
																	 and c.cli_cd_codigo_cliente = p.TenantId
	left join [10.1.1.21,1483].IrisysFiscal.dbo.tb_cte_participantes p2 with(nolock) on b2.bss_ds_cpf_cnpj = p2.CnpjCpf 
																	 and c.cli_cd_codigo_cliente = p2.TenantId
where
	r.Excluido = 0
	
	
GO
