-- ============================================================
-- BASELINE: dbo.UspProcessaRegrasPagamentoMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspProcessaRegrasPagamentoMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspProcessaRegrasPagamentoMotorista] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@Regra tinyint
)
as
begin
	
	SET NOCOUNT ON
	
	--declare @IdTransportadora int = 2087146923
	--declare @Ano int = 2023
	--declare @Mes tinyint = 9
	--declare @Quinzena tinyint = 2

	declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
	declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end
	
	--Regra 01
	--Para os motoristas que não utilizarem o app, seram penalizados e serão pagos com o frete do km mínimo
	if @Regra = 1
	begin
		--retorna os motoristas que utilizaram o app
		drop table if exists #base
		select 
			distinct
			users.cli_cd_codigo_cliente as Transportadora,
			users.usr_nm_usuario as Motorista,
			cast(gps.rgp_dh_data_hora as date) as Data
			into #base
		from 
			tb_registro_gps as gps with(nolock)
			join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
		where
			gps.rgp_dh_data_hora >= @data_inicial
			and gps.rgp_dh_data_hora < dateadd(day,1,@data_final)
		group by 
			users.usr_nm_usuario,
			cast(gps.rgp_dh_data_hora as date),
			users.cli_cd_codigo_cliente


		--atualiza saida dos motoristas da ALC que não utilizam o app para poder considerar a faixa minima
		update
			pagamento
		set
			Saida = SaidaKm0a100
		from 
			tb_fin_pagamento_motorista as pagamento
			join tb_clientes as clientes with(nolock) on pagamento.IdTransportadora = clientes.cli_id_logistics
			left join #base b on clientes.cli_cd_codigo_cliente = b.Transportadora 
								and pagamento.NomeMotorista = b.Motorista
								and pagamento.Data = b.Data
		where
			pagamento.IdTransportadora = @IdTransportadora
			and pagamento.Ano = @Ano
			and pagamento.Mes = @Mes
			and pagamento.Quinzena = @Quinzena
			and b.Data is null

	end --Fim da Regra 01

end
GO
