-- ============================================================
-- BASELINE: dbo.UspGetAppFinBravoxListarRotasSubTela
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetAppFinBravoxListarRotasSubTela]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC sp_describe_first_result_set N'exec UspGetMLFichaFinanceiroTransportadoraMotoristaID 5,132684245'

create procedure [dbo].[UspGetAppFinBravoxListarRotasSubTela] 
(
	@Transportadora int
	,@idrota varchar(50)
)as
	
SELECT  
			CAST(fin.Ano AS INT) AS Ano,
			CAST(fin.Mes AS INT) AS Mes,
			CAST(fin.Quinzena AS INT) AS Quinzena,
			CAST(ISNULL(tbinsert.ID, fin.IdRota) AS VARCHAR(50)) AS ID,
			CAST(fin.DataReferencia AS DATE) AS Data,
			CAST(ISNULL(tbinsert.[Hora Incio], fin.HoraInicio) AS VARCHAR(50)) AS [Hora Incio],
			CAST(ISNULL(tbinsert.[Service Center], fin.[ServiceCenter]) AS VARCHAR(50)) AS [Service Center],
			CAST(fin.[Placa] AS VARCHAR(10)) AS [Placa],
			CAST([Motorista] AS VARCHAR(100)) AS [Motorista],
			CAST(tbinsert.[Tipo de Contrato] AS VARCHAR(150)) AS [Tipo de Contrato],
			CAST(tbinsert.[Prazo] AS VARCHAR(150)) AS [Prazo],
			CAST(tbinsert.[Tipo de rota] AS VARCHAR(150)) AS [Tipo de rota],
			CAST(fin.[Cluster] AS VARCHAR(10)) AS [Cluster],
			CAST(ISNULL(tbinsert.Categoria, fin.[TipoVeiculo]) AS VARCHAR(150)) AS [Categoria],
			CAST(ISNULL(tbinsert.Ciclo, [CicloPM]) AS VARCHAR(10)) AS [Ciclo],
			CAST([QuantidadeParadas] AS SMALLINT) AS [Quantidade de Paradas],

			CAST(isnull(tbinsert.[Valor Saida] , fin.[PgtoSaida]) AS DECIMAL(8,2)) AS [Valor Saida],
            CAST(case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end AS DECIMAL(19,2)) AS [Valor Parada]	,
			-- CAST(fin.[PgtoParadas] AS DECIMAL(19,2)) AS [Valor Parada],
			CAST(case when tbinsert.[Tipo de rota] = 'Dividida' 
				then isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end	 ,fin.[PgtoTotal] ) / 2 
				else isnull(  tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.[PgtoParadas] end	 ,fin.[PgtoTotal] ) end AS DECIMAL(23,2)) AS [Total],
			CAST(ISNULL(tbinsert.KM, fin.[KmColetadoPagamento]) AS DECIMAL(9,2)) AS [KM],
		    
            CAST(ISNULL( tbinsert.faixakm , fin.[FaixaKmPagamento]) AS varchar(10)) AS [Faixa de kM],

			CAST(ISNULL(tbinsert.[Motorista recebedor], 0) AS INT) AS [Motorista recebedor],
			CAST(ISNULL(tbinsert.[Motorista recebedor 2], 0) AS INT) AS [Motorista recebedor 2],
			CAST(ISNULL(tbinsert.[Valores Extras], 0) AS DECIMAL(9,2)) AS [Valores Extras],
			CAST(ISNULL(tbinsert.[Valor de apoio], 0) AS DECIMAL(9,2)) AS [Valor de apoio],
			CAST(tbinsert.[OBS Valor de apoio] AS VARCHAR(1000)) AS [OBS Valor de apoio],
			CAST(ISNULL(tbinsert.[Valor Pedágio], 0) AS DECIMAL(9,2)) AS [Valor Pedágio],
			CAST(tbinsert.[OBS Valor Pedágio] AS VARCHAR(1000)) AS [OBS Valor Pedágio],
			CAST(ISNULL(tbinsert.[Valor Desconto], 0) AS DECIMAL(9,2)) AS [Valor Desconto],
			CAST(tbinsert.[OBS Valor Desconto] AS VARCHAR(1000)) AS [OBS Valor Desconto],
			CAST(ISNULL(tbinsert.[Valor Extra], 0) AS DECIMAL(9,2)) AS [Valor Extra],
			CAST(tbinsert.[OBS Valor Extra] AS VARCHAR(1000)) AS [OBS Valor Extra]

FROM vw_resultado_financeiro fin
	inner join tb_clientes as clientes
	on fin.IdTransportadora = clientes.cli_id_logistics
	left join 
			(
				select 
					idrota as idrotaapp
					,UsouAPP
				from vw_rotas_motoristas 
				where 1=1
				--and idrota = @rota
			)
			as usouapp
			on fin.idrota = usouapp.idrotaapp
	left join tb_fin_ficha_motorista as tbinsert
	on  clientes.cli_cd_codigo_cliente = tbinsert.IdTransportadora
	and fin.IdRota = tbinsert.id
where clientes.cli_cd_codigo_cliente = @Transportadora
	  and fin.IdRota =  @idrota
GO
