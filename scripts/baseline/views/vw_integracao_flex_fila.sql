-- ============================================================
-- BASELINE: dbo.vw_integracao_flex_fila
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_integracao_flex_fila]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_integracao_flex_fila]
as 

--select   7 as CodigoCliente,
--		 0 as IdRota,
--		 'FFQ7H59' as Placa,
--		 50 as SaldoLitros,
--		 200 as SaldoReais

select	top 100 cli.cli_cd_codigo_cliente as CodigoCliente,
		rotas.IdRota,
		rotas.Placa,
		parametros.ifp_vl_limite_litros as SaldoLitros,
		parametros.ifp_vl_limite_reais as SaldoReais
from	tb_ml_rotas as rotas
		join tb_dra_tipo_veiculo as tipos on rotas.tipoveiculo = tipos.tvl_nm_tipo_veiculo
		join tb_bases as bases on rotas.ServiceCenter = bases.bss_ds_sigla and rotas.IdTransportadora = bases.bss_cd_idtransportadora
		join tb_clientes as cli on rotas.idtransportadora = cli.cli_id_logistics
		join tb_integracao_flex_parametros as parametros
				on cli.cli_cd_codigo_cliente = parametros.ifp_cd_cliente
				and (tipos.tvl_cd_tipo_veiculo = parametros.ifp_cd_tipo_veiculo or parametros.ifp_cd_tipo_veiculo is null)
				and (bases.bss_cd_base = parametros.ifp_cd_base or parametros.ifp_cd_base is null)
left	join (
				select	distinct inf_cd_id_rota as IdRota
				from	tb_integracao_flex_logs
				where	cast(inf_dh_data_hora as date) = cast(getdate() as date)
						and inf_nm_status = 200
			) as atualizados
		on rotas.IdRota = atualizados.IdRota

where	DataReferencia = cast(getdate() as date) 
		and Excluido = 0
		and StatusRota <> 'planned'
		and atualizados.IdRota is null

GO
