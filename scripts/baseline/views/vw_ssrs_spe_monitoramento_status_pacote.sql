-- ============================================================
-- BASELINE: dbo.vw_ssrs_spe_monitoramento_status_pacote
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_spe_monitoramento_status_pacote]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_ssrs_spe_monitoramento_status_pacote] as 


select 
idtransportadora
,servicecenter
,CompradorAusente
,NegocioFechado
,EnderecoRuim
,Compradorrejeitado
,ForaRota
,ProblemasMecanicos
,MotoristaSemTempo
,FalhaAplicativo
,AreaRisco
,ClienteMudou
,Outros
,Perdido

from tb_ssrs_spe_monitoramento_status_pacote nolock

where DataReferencia = cast(dateadd(hour,-2,getdate()) as date)


/*

SELECT

	a.idtransportadora,
	NomeHub as servicecenter,
	COUNT(CASE WHEN a.SubStatus = 'O comprador não está em casa' THEN 1 END) AS CompradorAusente,
	COUNT(CASE WHEN a.SubStatus = 'Comércio Fechado' THEN 1 END) AS NegocioFechado,
	COUNT(CASE WHEN a.SubStatus = 'Endereço não encontrado' THEN 1 END) AS EnderecoRuim,
	COUNT(CASE WHEN a.SubStatus = 'Rejeitado pelo usuário' THEN 1 END) AS Compradorrejeitado,
	COUNT(CASE WHEN a.SubStatus = 'Fora de Rota' THEN 1 END) AS ForaRota,
	COUNT(CASE WHEN a.SubStatus = 'Problemas Mecânicos' THEN 1 END) AS ProblemasMecanicos,
	COUNT(CASE WHEN a.SubStatus = 'O motorista não tem tempo suficiente' THEN 1 END) AS MotoristaSemTempo,
	COUNT(CASE WHEN a.SubStatus = 'Falha de aplicativo/Internet' THEN 1 END) AS FalhaAplicativo,
	COUNT(CASE WHEN a.SubStatus = 'Área de Risco' THEN 1 END) AS AreaRisco,
	COUNT(CASE WHEN a.SubStatus = 'Cliente se Mudou' THEN 1 END) AS ClienteMudou,
	count(CASE WHEN a.StatusEntrega = 'Não Entregue' THEN 1 END) Outros,
	COUNT(CASE WHEN a.SubStatus = 'Item perdido' THEN 1 END) AS Perdido

 
FROM
  vw_pacotes_spe_v4 as a
  inner join vw_rotas_spe_v4 as b
  on a.codigorota = b.codigorota 

WHERE 1=1
and cast(b.DataHoraInicio as date) = cast(dateadd(hour,-2,getdate()) as date) -- NÃO ALTERAR, USADO PARA ENVIOS NOS FECHAMENTOS DIÁRIOS
and a.DataReferencia = cast(dateadd(hour,-2,getdate()) as date) -- NÃO ALTERAR, USADO PARA ENVIOS NOS FECHAMENTOS DIÁRIOS

group by a.idtransportadora,NomeHub

*/
GO
