-- ============================================================
-- BASELINE: dbo.vw_taxa_ocupacao_veiculos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_taxa_ocupacao_veiculos]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_taxa_ocupacao_veiculos]

as

select periodo.TenantId,
	   datas.Data,
	   periodo.Placa,
	   periodo.NomeMotorista,
	   periodo.TipoVeiculo,
	   periodo.CategoriaVeiculo,
	   1 as Ativo,
	   case when rotas.Placa is null then 0 else 1 end as Rodado
from DimData as datas
	join (
			select clientes.cli_cd_codigo_cliente as TenantId,
				   rotas.Placa,
				   min(DataReferencia) as Inicio,
				   max(DataReferencia) as Fim,
				   max(
						CASE
							WHEN TipoVeiculo LIKE '%Rental%' OR TipoVeiculo LIKE '%Frota Fixa%' THEN 'Frota Fixa'
							ELSE 'Agregado'
						END
					) AS CategoriaVeiculo,
					max(TipoVeiculo) as TipoVeiculo,
					max(NomeMotorista) as NomeMotorista
			from tb_ml_rotas as rotas
				join tb_clientes as clientes on rotas.IdTransportadora = clientes.cli_id_logistics and clientes.cli_in_ativo = 1
			where rotas.DataReferencia >= '2024-06-01'
				  and Excluido = 0
				  --and placa = 'PZB0G96'
				  and clientes.cli_cd_codigo_cliente <> 7
				  and clientes.cli_cd_codigo_cliente = 37
			group by clientes.cli_cd_codigo_cliente,
					 rotas.Placa
		) as periodo
	on datas.Data between periodo.Inicio and periodo.Fim
	left join (select Placa, DataReferencia from tb_ml_rotas where Excluido = 0 group by Placa, DataReferencia) as rotas
	on periodo.Placa = rotas.Placa
	and datas.Data = rotas.DataReferencia
--order by data 

--select * from tb_clientes
GO
