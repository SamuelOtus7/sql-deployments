-- ============================================================
-- BASELINE: dbo.vw_financeiro_a_receber_divergencias
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_financeiro_a_receber_divergencias]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vw_financeiro_a_receber_divergencias]
as

select 
	IdTransportadora,
	DataReferencia,
	IdQuinzena,
	FORMAT(DataReferencia,'MMM') + ' - '+ Quinzena Quinzena,
	DataAtualizacao,
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
	Resultado,
	DataAtualizacaoControlePowerBI

from 
	(
	select 
		a.idtransportadora IdTransportadora,
		a.IdRota as Rota,
		a.DataReferencia,
		a.IdQuinzena,
        a.mes,
		case 
			when a.Quinzena = 1 then '1 Qz'
			when a.Quinzena = 2 then '2 Qz'
		end Quinzena,
		a.DataAtualizacaoControlePowerBI,
		a.DataAtualizacao,
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
		Total as TotalPrefatura,
		RecebTotal,
		DescontoCicloPM,
		RecebimentoDomingo,
		case when kmciclo = 'AMBULANCE' then 'Sim' else null end Ambulancia ,
		case		
			when RecebTotal = TotalPrefatura then 'Valores iguais'
			when kmciclo = 'AMBULANCE' then 'Ambulancia'
			when fat.idrota is null then 'Ausente na prefatura'
			when a.TotalPrefatura = 0  then 'Valor zerado na Prefatura'
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

	from (
			SELECT	VRF.*,
					CLI.cli_id_logistics
			FROM vw_resultado_financeiro AS VRF
			LEFT JOIN tb_clientes		 AS CLI ON CLI.cli_cd_codigo_cliente = IdTransportadora
		  ) as a
		left join vw_fin_prefatura as fat on a.idrota  = fat.idrota
								AND a.cli_id_logistics = fat.IdTransportadora
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
		-- and a.idtransportadora = 47
		-- and a.mes = 1
		-- and a.quinzena = 2
	) as base  
 --where rota = 194284112


GO
