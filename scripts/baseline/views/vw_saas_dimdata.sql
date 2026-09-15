-- ============================================================
-- BASELINE: dbo.vw_saas_dimdata
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_dimdata]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_saas_dimdata]
as

select
  Data,
  DiaDaSemana,
  DataSemanaAno,
  DiaMes,
  Quinzena,
   case
    when Quinzena = 1 then '1º Quin.'else '2º Quin.' end as Quinzena_2,
  Mes,
  MesAbreviado,
  NumMes,
  MesAno,
  Ano,
  Feriado,
   case
    when DiaDaSemana = 'domingo' or Feriado = 1 then 'Dom. Fer.'
    when DiaDaSemana = 'sábado' then 'Sáb.'
    else 'Seg-Sex' end as PeriodoDia, -- INSERIDA POR MURILO 08/06 PARA RELATÓRIO DE ANALISE GERENCIAL
  REPLACE(FORMAT(MIN(Data) OVER (PARTITION BY DATEDIFF(DAY, '19000101', Data) / 7), 'dd/MMM', 'pt-BR'), '.', '') AS InicioSemana2, --INSERIDA POR MURILO 08/06 PARA RELATÓRIO DE ANALISE GERENCIAL
  MIN(Data) OVER (PARTITION BY DATEDIFF(DAY, '19000101', Data) / 7) AS InicioSemana 
from
  DimData
where
  Data between '2024-08-01' and cast(getdate() as date)
GO
