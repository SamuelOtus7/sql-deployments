-- ============================================================
-- BASELINE: dbo.vw_financeiro_divergencias
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_divergencias]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_financeiro_divergencias]
as

select 
	IdTransportadora,
	DataReferencia,
	IdPeriodo,
	Periodo,
	Rota,
	Ambulancia,
	servicecenter ,
	XPT,
	Placa,
	Motorista,
	TipoVeiculo,
	TipoVeiculoPreFatura,
	CicloPM,
	FaixaPreFatura,
	FaixaKm,
	DescontoCicloPM,
	RecebimentoDomingo,
	RecebTotal,
	TotalPrefatura,
	TotalPrefatura-RecebTotal as DeltaPrefatura,
	Resultado
from 
	(
	select 
		a.idtransportadora IdTransportadora,
		a.IdRota as Rota,
		a.DataReferencia,
		cast(cast(a.Ano as varchar(4)) + cast(a.Mes as varchar(2)) + cast(a.Quinzena as varchar(1)) as int) IdPeriodo,
		'Q' + CAST(a.Quinzena AS VARCHAR(1)) + ' ' +
		CASE a.Mes
			WHEN 1 THEN 'Janeiro'
			WHEN 2 THEN 'Fevereiro'
			WHEN 3 THEN 'Março'
			WHEN 4 THEN 'Abril'
			WHEN 5 THEN 'Maio'
			WHEN 6 THEN 'Junho'
			WHEN 7 THEN 'Julho'
			WHEN 8 THEN 'Agosto'
			WHEN 9 THEN 'Setembro'
			WHEN 10 THEN 'Outubro'
			WHEN 11 THEN 'Novembro'
			WHEN 12 THEN 'Dezembro'
		END + ' ' + 
		CAST(a.Ano AS VARCHAR(4)) AS Periodo,
		a.servicecenter,
		XPT,
		a.Placa,
		a.Motorista,
		TipoVeiculo,
		TipoVeiculoPreFatura,
		a.CicloPM,
		isnull(FaixaKm,-1) as FaixaKm,
		isnull(FaixaPreFatura,0)  as FaixaPreFatura,
		ValorFinal ,
		RecebMeli, 
		TotalPrefatura,
		RecebTotal,
		DescontoCicloPM,
		RecebimentoDomingo,
		case when kmciclo = 'AMBULANCE' then 1 else null end Ambulancia ,
		case		
			when RecebTotal = TotalPrefatura then 'Valores iguais'
			when kmciclo = 'AMBULANCE' then 'Ambulancia'
			when TotalPrefatura = 0  then 'Valor zerado na Prefatura'
			when b.bft_cd_service_center is null  then 'Sem base frete cadastrada'
			when a.ServiceCenter <> serviceCenterPrefatura then 'Service Center diferente'
			when a.TipoVeiculo <> TipoVeiculoPreFatura then 'Tipo de veiculo diferente'
			when a.CicloPM <> CicloPMFatura then 'Ciclo diferente'
			when isnull(FaixaPreFatura,0) <> isnull(FaixaKm,-1) then 'Faixa de KM diferente'
			when DescontoCicloPM <>  (TotalPrefatura-RecebTotal) then 'Outros'
			--when a.Adicional <> adicion
		else 
			'Outros'
		end as Resultado
	from  
		vw_resultado_financeiro as a
		left join tb_fin_prefatura as fat on a.idrota = fat.idrota
		left join (
					select 
						bft_cd_service_center,
						tvl_nm_tipo_veiculo,
						bft_cd_transportadora
					from 
						tb_fin_base_frete_transportadora as a
						inner join  tb_dra_tipo_veiculo as b on a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo
					where 
						bft_vl_frete > 0
					group by 
						bft_cd_service_center,
						tvl_nm_tipo_veiculo,
						bft_cd_transportadora
					) as b on a.servicecenter = b.bft_cd_service_center
							and  a.tipoveiculo = b.tvl_nm_tipo_veiculo
							and a.idtransportadora = b.bft_cd_transportadora
	where 
		a.Ano >= 2024
		--a.idtransportadora = @idtransportadora
		--and a.mes = 11
		--and a.quinzena = 2
		--and a.datareferencia between @data_ini and @data_fim
	) as base  
 --where rota = 194284112


GO
