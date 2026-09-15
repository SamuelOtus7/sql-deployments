-- ============================================================
-- BASELINE: dbo.UspMLAtualizaTipoVeiculo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaTipoVeiculo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspMLAtualizaTipoVeiculo]
as 
begin

	SET NOCOUNT ON;

	update 
		a
	set 
		vei_ds_tipo_logistics = b.tipoveiculo
	from 
		tb_veiculos a
		join tb_clientes c on a.vei_cd_cliente = c.cli_cd_codigo_cliente
		join (
			select 
				a.IdTransportadora,
				a.placa,
				max(TipoVeiculo) as TipoVeiculo 
			from 
				tb_ml_rotas a
				join (
					select 
						IdTransportadora,
						placa,
						max(DataReferencia) as data 
					from 
						tb_ml_rotas 
					where 
						TipoVeiculo <> '' 
					group by 
						IdTransportadora,
						placa
				) b
				on a.IdTransportadora = b.IdTransportadora and a.Placa = b.Placa and a.DataReferencia = b.data
		group by  
			a.IdTransportadora,
			a.Placa
		) b on a.vei_ds_placa = b.Placa and c.cli_id_logistics = b.IdTransportadora

end
GO
