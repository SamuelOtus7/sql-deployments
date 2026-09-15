-- ============================================================
-- BASELINE: dbo.vw_ssrs_ml_monitoramento_status_pacote_teste
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_ssrs_ml_monitoramento_status_pacote_teste]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_ssrs_ml_monitoramento_status_pacote_teste] as 

SELECT
a.idtransportadora,
servicecenter,
OrigemSaida,
--a.idrota,
  COUNT(CASE WHEN a.SubStatus = 'Comprador Ausente' THEN 1 END) AS CompradorAusente,
  COUNT(CASE WHEN a.SubStatus = 'Negócio Fechado' THEN 1 END) AS NegocioFechado,
  COUNT(CASE WHEN a.SubStatus = 'Endereço Inválido' THEN 1 END) AS EnderecoRuim,
  COUNT(CASE WHEN a.SubStatus = 'Comprador Rejeitado' THEN 1 END) AS CompradorRejeitado,
  COUNT(CASE WHEN a.SubStatus = 'Erro de Rota' THEN 1 END) AS ErroDeRota,
  COUNT(CASE WHEN a.SubStatus = 'Bloqueado por Palavra Chave' THEN 1 END) AS BloqueadoPorPalavraChave,
  0 AS Bloqueado,
  COUNT(CASE WHEN a.SubStatus = 'Perdido' THEN 1 END) AS Perdido,
  COUNT(CASE WHEN a.SubStatus = 'Endereço não Visitado' THEN 1 END) AS EnderecoNaoVisitado,
  COUNT(CASE WHEN a.SubStatus = 'Endereço Inacessível' THEN 1 END) AS EnderecoInacessivel,
  COUNT(CASE WHEN a.SubStatus = 'Cancelado' THEN 1 END) AS Cancelado,
  COUNT(CASE WHEN a.SubStatus = 'Comprador mudou' THEN 1 END) AS CompradorMudou,
  COUNT(CASE WHEN SubStatus is not null and a.StatusEntrega = 'Não Entregue' and  a.SubStatus not in ('Comprador Ausente','Negócio Fechado','Endereço Inválido','Comprador Rejeitado',
										'Erro de Rota','Bloqueado por Palavra Chave','Perdido',
										'Endereço não Visitado','Endereço Inacessível','Comprador mudou','Cancelado','Transferido') THEN 1 END) AS Outros,
  COUNT(CASE WHEN a.StatusEntrega = 'Não Entregue' and a.SubStatus not in ('Transferido') THEN 1 END) AS insucesso
  
 
--FROM
--  vw_pacotes_diaatual as a
--  inner join vw_rotas_diaatual as b
--  on a.idrota = b.idrota 

FROM
  vw_pacotes as a
  inner join vw_rotas as b
  on a.idrota = b.idrota 



WHERE
  SubStatus IS NOT NULL
  and b.StatusRota <> 'Planejada'
  and a.DataReferencia = '2024-07-03'
 -- and a.idtransportadora = 643493085
  --and ServiceCenter = 'SSP23'

  group by a.idtransportadora,servicecenter,OrigemSaida--,a.idrota
GO
