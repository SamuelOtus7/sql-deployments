-- ============================================================
-- BASELINE: dbo.UspGetExportPagamentoMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGetExportPagamentoMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGetExportPagamentoMotorista] 
(
	@ano int,
	@mes tinyint,
	@quinzena tinyint,
	@idcliente int,
	@base varchar(30)
) as

--declare
--	  @ano int		= 2024 ,
--	  @mes tinyint		= 07,
--	  @quinzena tinyint = 1,
--	  @idcliente int	= 5,
--	  @base varchar(30) = 'SMS2'

select 
ROW_NUMBER () over(partition by OrdemMotorista order by OrdemMotorista,Data ) as ordem
,IdRota	
,Ano	
,Mes	
,Quinzena	
,Data
,[Hora Início]
,[Service Center]
,Placa	
,[Tipo Motorista]	
,Motorista	
,[Tipo de Contrato]	
,Prazo	
,[Tipo de rota]	

,Motorista1	as [Motorista Recebedor]
,[Tipo de Contrato1] as [Tipo de Contrato Recebedor] 
,Prazo1	as [Prazo Recebedor]
,[Tipo de rota1] as [Tipo de Rota Recebedor]


,Cluster	
,Categoria	
,Ciclo	
,[Quantidade de Paradas]	
,[Valor Saída]	
,[Valor Parada]	
,Total	
,usouapp
,KM	
,[Faixa de KM]	
,[Valor de apoio]
,[OBS Valor de apoio]
,[Valor Pedágio]	
,[OBS Valor Pedágio]
,[Valor Desconto]
,[OBS Valor Desconto]
,[Valor Extra]
,[OBS Valor Extra]


from(
SELECT 
	*
FROM 
(

SELECT  distinct 
	     fin.Motorista as OrdemMotorista
		,fin.IdRota
		,fin.Ano
	    ,fin.Mes
	    ,fin.Quinzena
	    ,convert(varchar,fin.DataReferencia,103) as Data
		,isnull(tbinsert.[Hora Incio],fin.HoraInicio)		as [Hora Início]
	    ,isnull(tbinsert.[Service Center],fin.ServiceCenter) as [Service Center]
	    ,fin.Placa
		,'Motorista Recebedor 1' as [Tipo Motorista]
	    ,fin.Motorista					
	    ,tbinsert.[Tipo de Contrato]
	    ,tbinsert.Prazo				
	    ,tbinsert.[Tipo de rota]	

	    ,usu.usr_nm_usuario as Motorista1					
	    ,tbinsert1.[Tipo de Contrato] as [Tipo de Contrato1]
	    ,tbinsert1.Prazo as Prazo1				
	    ,tbinsert1.[Tipo de rota] as [Tipo de rota1]


	    ,fin.Cluster
	    ,isnull(tbinsert.Categoria,fin.TipoVeiculo)	as Categoria
	    ,isnull(tbinsert.Ciclo,CicloPM)	as Ciclo
	    ,QuantidadeParadas as [Quantidade de Paradas]
	    ,FORMAT(isnull(tbinsert.[Valor Saida],fin.PgtoSaida), 'C', 'pt-BR') as [Valor Saída]
	    ,FORMAT( case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.PgtoParadas end , 'C', 'pt-BR')as [Valor Parada]
		, FORMAT( (isnull(tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.PgtoParadas end ,fin.PgtoTotal ) --Valor Saída
			/ case when tbinsert.[Tipo de rota] = 'Dividida' then 2 else 1 end) -- Dividir por 2 para rota dividida
			+ isnull(tbinsert.[Valor Pedágio],0)
			+ isnull(tbinsert.[Valor de apoio],0)
			+ isnull(tbinsert.[Valor Desconto],0)*-1
			+ isnull(tbinsert.[Valor Extra],0) , 'C', 'pt-BR')
		 as Total
		 
	    ,isnull(tbinsert.KM,fin.KmColetadoPagamento) as KM
		, CAST(ISNULL( tbinsert.faixakm , fin.FaixaKmPagamento) AS varchar(10)) AS [Faixa de KM]
		,FORMAT(isnull(tbinsert.[Valor de apoio],0), 'C', 'pt-BR') as [Valor de apoio]
		,tbinsert.[OBS Valor de apoio]
		,FORMAT(isnull(tbinsert.[Valor Pedágio],0), 'C', 'pt-BR') as [Valor Pedágio]
		,tbinsert.[OBS Valor Pedágio]
		,FORMAT(isnull(tbinsert.[Valor Desconto]*-1,0), 'C', 'pt-BR') as [Valor Desconto] 
		,tbinsert.[OBS Valor Desconto]
		,FORMAT(isnull(tbinsert.[Valor Extra],0), 'C', 'pt-BR')  as [Valor Extra]
		,tbinsert.[OBS Valor Extra]
		,usouapp


from vw_resultado_financeiro fin

	left join tb_fin_ficha_motorista as tbinsert
	on  fin.IdTransportadora = tbinsert.IdTransportadora
	and fin.IdRota = tbinsert.id

	left join tb_fin_ficha_motorista as tbinsert1
	on  fin.IdTransportadora = tbinsert1.IdTransportadora
	and fin.IdRota = tbinsert1.id

	left join tb_usuario as usu
	on tbinsert1.[Motorista recebedor] = usr_cd_usuario


	

where 1 = 1
	--and fin.IdRota = '149215319'
	and fin.IdTransportadora = @idcliente
	and fin.Ano		 = @ano
	and fin.Mes		 = @mes
	and fin.Quinzena = @quinzena
	and fin.ServiceCenter = @base

union all

SELECT  distinct 
	     fin.Motorista
		,fin.IdRota
		,fin.Ano
	    ,fin.Mes
	    ,fin.Quinzena
	    ,convert(varchar,fin.DataReferencia,103) as Data
		,isnull(tbinsert.[Hora Incio],fin.HoraInicio)		as [Hora Início]
	    ,isnull(tbinsert.[Service Center],fin.ServiceCenter) as [Service Center]
	    ,fin.Placa
		,'Motorista Recebedor 2' as [Tipo Motorista]

		,fin.Motorista					
	    ,tbinsert.[Tipo de Contrato]
	    ,tbinsert.Prazo				
	    ,tbinsert.[Tipo de rota]

		,users.usr_nm_usuario as Motorista
	    ,tbinsert.TipoContratoMotoristaRecebedor2
	    ,tbinsert.PrazoMotoristaRecebedor2				
	    ,tbinsert.[Tipo de rota]	



	    ,fin.Cluster
	    ,isnull(tbinsert.Categoria,fin.TipoVeiculo)	as Categoria
	    ,isnull(tbinsert.Ciclo,CicloPM)	as Ciclo
	    ,QuantidadeParadas as [Quantidade de Paradas]
	    ,FORMAT(isnull(tbinsert.[Valor Saida],fin.PgtoSaida) , 'C', 'pt-BR') as [Valor Saída]
	    ,FORMAT(case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.PgtoParadas end , 'C', 'pt-BR') as [Valor Parada]
		,FORMAT( (isnull(tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.PgtoParadas end ,fin.PgtoTotal ) --Valor Saída
			/ case when tbinsert.[Tipo de rota] = 'Dividida' then 2 else 1 end) -- Dividir por 2 para rota dividida
			+ isnull(ValorApoio2,0)
			+ isnull(tbinsert.ValorPedagio2,0)
			+ (isnull(tbinsert.ValorDesconto2,0)*-1)
			+ isnull(tbinsert.ValorExtra2,0)  , 'C', 'pt-BR')
		 as Total
	    ,isnull(tbinsert.KM,fin.KmColetadoPagamento) as KM
	    ,CAST(ISNULL( tbinsert.faixakm , fin.FaixaKmPagamento) AS varchar(10)) AS [Faixa de KM]
		,FORMAT(isnull(tbinsert.ValorApoio2,0), 'C', 'pt-BR') ValorApoio2
		,tbinsert.OBSValordeapoio2
		,FORMAT(isnull(tbinsert.ValorPedagio2,0), 'C', 'pt-BR') ValorPedagio2
		,tbinsert.ObsValorPedagio2
		,FORMAT(isnull(tbinsert.ValorDesconto2*-1,0), 'C', 'pt-BR') ValorDesconto2
		,tbinsert.ObsValorDesconto2
		,FORMAT(isnull(tbinsert.ValorExtra2,0), 'C', 'pt-BR') ValorExtra2
		,tbinsert.ObsValorExtra2
		,usouapp

from vw_resultado_financeiro fin

	join tb_fin_ficha_motorista as tbinsert
	on  fin.IdTransportadora = tbinsert.IdTransportadora
	and fin.IdRota = tbinsert.id
	
	join tb_usuario as users
	on tbinsert.[Motorista recebedor 2] = users.usr_cd_usuario

where 1 = 1
	and [Tipo de rota] = 'Dividida'
	--and fin.IdRota = '149215319'
	and fin.IdTransportadora = @idcliente
	and fin.Ano		 = @ano
	and fin.Mes		 = @mes
	and fin.Quinzena = @quinzena
	and fin.ServiceCenter = @base
	
union all

SELECT  distinct 
	     fin.Motorista
		,fin.IdRota
		,fin.Ano
	    ,fin.Mes
	    ,fin.Quinzena
	    ,convert(varchar,fin.DataReferencia,103) as Data
		,isnull(tbinsert.[Hora Incio],fin.HoraInicio) as [Hora Início]
	    ,isnull(tbinsert.[Service Center],fin.ServiceCenter) as [Service Center]
	    ,fin.Placa
		,'Motorista Apoio' as [Tipo Motorista]
	    
		,fin.Motorista	as Motorista
	    ,tbinsert.[Tipo de Contrato]
	    ,tbinsert.Prazo				
	    ,tbinsert.[Tipo de rota]	

		,users.usr_nm_usuario as Motorista
	    ,tbinsert.TipoContratoMotoristaRecebedorApoio
	    ,tbinsert.PrazoMotoristaRecebedorApoio				
	    ,null [Tipo de rota]	
	

	    ,fin.Cluster
	    ,isnull(tbinsert.Categoria,fin.TipoVeiculo)	as Categoria
	    ,isnull(tbinsert.Ciclo,CicloPM)	as Ciclo
	    ,QuantidadeParadas as [Quantidade de Paradas]
	    ,FORMAT(0, 'C', 'pt-BR') as [Valor Saída]
	    ,FORMAT(0, 'C', 'pt-BR') as [Valor Parada]
		,FORMAT(
		/*(isnull(tbinsert.[Valor Saida] + case when tbinsert.[Tipo de Contrato] = 'Motorista' then 0 else  fin.PgtoParadas end ,fin.PgtoTotal ) --Valor Saída
			/ case when tbinsert.[Tipo de rota] = 'Dividida' then 2 else 1 end) -- Dividir por 2 para rota dividida
			+*/ isnull(ValorApoio_mt_apoio,0)
			+ isnull(tbinsert.ValorPedágio_mt_apoio,0)
			+ (isnull(tbinsert.ValorDesconto_mt_apoio,0)*-1)
			+ isnull(tbinsert.ValorExtra_mt_apoio,0) , 'C', 'pt-BR')
		 as Total
	    ,isnull(tbinsert.KM,fin.KmColetadoPagamento) as KM
	    ,CAST(ISNULL( tbinsert.faixakm , fin.FaixaKmPagamento) AS varchar(10)) AS [Faixa de KM]
		
		,FORMAT(ISNULL(tbinsert.ValorApoio_mt_apoio,0), 'C', 'pt-BR') ValorApoio_mt_apoio
		,tbinsert.OBSValordeapoio_mt_apoio
		,FORMAT(ISNULL(tbinsert.ValorPedágio_mt_apoio,0), 'C', 'pt-BR') ValorPedágio_mt_apoio
		,tbinsert.OBSValorPedágio_mt_apoio
		,FORMAT(ISNULL(tbinsert.ValorDesconto_mt_apoio,0)*-1, 'C', 'pt-BR') ValorDesconto_mt_apoio
		,tbinsert.OBSValorDesconto_mt_apoio
		,FORMAT(ISNULL(tbinsert.ValorExtra_mt_apoio,0), 'C', 'pt-BR') ValorExtra_mt_apoio
		,tbinsert.OBSValorExtra_mt_apoio
		,usouapp

from 
	vw_resultado_financeiro fin

	join tb_fin_ficha_motorista as tbinsert
	on  fin.IdTransportadora = tbinsert.IdTransportadora
	and fin.IdRota = tbinsert.id

	join tb_usuario as users
	on tbinsert.MotoristaRecebedorApoio = users.usr_cd_usuario



where 1 = 1
	--and [Tipo de rota] = 'Dividida'
	--and fin.IdRota = '149215319'
	and fin.IdTransportadora = @idcliente
	and fin.Ano		 = @ano
	and fin.Mes		 = @mes
	and fin.Quinzena = @quinzena
	and fin.ServiceCenter = @base

) AS a
) as tabela
where 1=1 
--AND IdRota = 149215319
--and Motorista LIKE '%ABNAEL%'

--select * from tb_usuario
--where usr_cd_usuario = 8674



--SELECT * FROM tb_fin_ficha_motorista WHERE ID =149215319




GO
