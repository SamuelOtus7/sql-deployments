-- ============================================================
-- BASELINE: dbo.UspGetMLFichaFinanceiroTransportadoraMotoristaID
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetMLFichaFinanceiroTransportadoraMotoristaID]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspGetMLFichaFinanceiroTransportadoraMotoristaID]  
(
	@Transportadora int
	,@idrota varchar(50)
)as
	
	
--declare	@Transportadora int = 5
--	,@idrota varchar(50) = 146761441

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
		    
            CAST(                    ISNULL( tbinsert.faixakm , fin.[FaixaKmPagamento]) AS varchar(10)                    ) AS [Faixa de kM],

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
			CAST(tbinsert.[OBS Valor Extra] AS VARCHAR(1000)) AS [OBS Valor Extra],

			CAST(ISNULL(tbinsert.ValorApoio_mt_apoio, 0) AS DECIMAL(9,2)) AS ValorApoio_mt_apoio,
			CAST(tbinsert.OBSValordeapoio_mt_apoio AS VARCHAR(1000)) AS OBSValordeapoio_mt_apoio,
			CAST(ISNULL(tbinsert.ValorPedágio_mt_apoio, 0) AS DECIMAL(9,2)) AS ValorPedágio_mt_apoio,
			CAST(tbinsert.OBSValorPedágio_mt_apoio AS VARCHAR(1000)) AS OBSValorPedágio_mt_apoio,
			CAST(ISNULL(tbinsert.ValorDesconto_mt_apoio, 0) AS DECIMAL(9,2)) AS ValorDesconto_mt_apoio,
			CAST(tbinsert.OBSValorDesconto_mt_apoio AS VARCHAR(1000)) AS OBSValorDesconto_mt_apoio,
			CAST(ISNULL(tbinsert.ValorExtra_mt_apoio, 0) AS DECIMAL(9,2)) AS ValorExtra_mt_apoio,
			CAST(tbinsert.OBSValorExtra_mt_apoio AS VARCHAR(1000)) AS OBSValorExtra_mt_apoio,
			CAST(isnull(PrazoMotoristaRecebedor2			,0)	AS VARCHAR(1000)) as PrazoMotoristaRecebedor2	,			
			CAST(isnull(TipoContratoMotoristaRecebedor2 	,0)	AS VARCHAR(1000)) as TipoContratoMotoristaRecebedor2 		,
			CAST(isnull(MotoristaRecebedor2 				,0)	AS int) as MotoristaRecebedor2 ,					
			CAST(isnull(ValorApoio2 						,0)	AS DECIMAL(9,2)) as ValorApoio2, 							
			CAST(isnull(OBSValordeapoio2 					,0)	AS VARCHAR(1000)) as OBSValordeapoio2, 						
			CAST(isnull(ValorPedagio2 						,0)	AS DECIMAL(9,2)) as ValorPedagio2, 							
			CAST(isnull(ObsValorPedagio2					,0)	AS VARCHAR(1000)) as ObsValorPedagio2,						
			CAST(isnull(ValorDesconto2 					,0)	AS DECIMAL(9,2)) as ValorDesconto2, 						
			CAST(isnull(ObsValorDesconto2 					,0)	AS VARCHAR(1000)) as ObsValorDesconto2, 						
			CAST(isnull(ValorExtra2 						,0)	AS DECIMAL(9,2)) as ValorExtra2, 							
			CAST(isnull(ObsValorExtra2						,0)	AS VARCHAR(1000)) as ObsValorExtra2,							
			CAST(isnull(PrazoMotoristaRecebedorApoio 		,0)	AS VARCHAR(1000)) as PrazoMotoristaRecebedorApoio, 			
			CAST(isnull(TipoContratoMotoristaRecebedorApoio,0) 	AS VARCHAR(1000)) as TipoContratoMotoristaRecebedorApoio, 	
			CAST(isnull(MotoristaRecebedorApoio 			,0)	AS int) as MotoristaRecebedorApoio 				





FROM vw_resultado_financeiro fin
	inner join tb_clientes as clientes
	on fin.IdTransportadora = clientes.cli_cd_codigo_cliente

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


--alter table tb_fin_ficha_motorista add PrazoMotoristaRecebedor2	VARCHAR(150)
--alter table tb_fin_ficha_motorista add TipoContratoMotoristaRecebedor2 VARCHAR(150)
--alter table tb_fin_ficha_motorista add MotoristaRecebedor2 int
--alter table tb_fin_ficha_motorista add OBSValordeapoio2 VARCHAR(150)
--alter table tb_fin_ficha_motorista add ValorApoio2 decimal(10,2)
--alter table tb_fin_ficha_motorista add ValorPedagio2 decimal(10,2)
--alter table tb_fin_ficha_motorista add ValorDesconto2 decimal(10,2)
--alter table tb_fin_ficha_motorista add ValorExtra2 decimal(10,2)
--alter table tb_fin_ficha_motorista add ObsValorPedagio2 VARCHAR(150)
--alter table tb_fin_ficha_motorista add ObsValorDesconto2 VARCHAR(150)
--alter table tb_fin_ficha_motorista add ObsValorExtra2 VARCHAR(150)
--alter table tb_fin_ficha_motorista add PrazoMotoristaRecebedorApoio VARCHAR(150)
--alter table tb_fin_ficha_motorista add TipoContratoMotoristaRecebedorApoio  VARCHAR(150)
--alter table tb_fin_ficha_motorista add MotoristaRecebedorApoio VARCHAR(150)



	  --select * from tb_fin_ficha_motorista
GO
