-- ============================================================
-- BASELINE: dbo.vw_rotas_ORH
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rotas_ORH]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[vw_rotas_ORH]
AS

select
Idtransportadora,
IdRota,
DataReferencia,
dataultimaentrega,
Datahorainicio,
CAST(Datahorainicio AS date) AS DataInicio,
format(DataHoraInicio, 'HH:mm')  as HoraInicio,
StatusRota,
SubStatusRota,
ServiceCenter,
case when servicecenter <> origemsaida and LEFT(origemsaida,1) = 'E' then origemsaida else servicecenter end Base,
OrigemSaida,
null as  CidadeBase,
TipoVeiculo,
NomeMotorista,
TotalPacotes,
PacotesEntregues,
PacotesPendentes,
PacotesNaoEntregue,
TempoEmRota,
TempoEmRota / 60 AS HorasEmRota,
CAST(TempoEmRota AS float) / 1440.0 AS TempoemRotaHoras,
TempoAreaEntrega,
CAST(DATEADD(MINUTE,TempoAreaEntrega, '00:00:00') AS time(0)) AS TempoAreaEntregaHoras,
TempoChegadaAreaEntrega,
CAST(DATEADD(MINUTE,TempoChegadaAreaEntrega, '00:00:00') AS time(0)) AS ChegadaAreaEntregaHoras,
TempoPlanejadoMinutos,
DATEADD(
    MINUTE,
    Tempoplanejadominutos,
    Datahorainicio
) AS DataHoraFimPrevista,
CAST(TempoPlanejadoMinutos AS float) / 1440.0 AS TempoPlanejadoHoras,
case
  when TempoEmRota > TempoPlanejadoMinutos then 'Fora do ORH'
  else 'Dentro Do ORH' end as Situacao,
KmTotal
from
tb_ml_rotas with(nolock)
WHERE
    statusrota <> 'planned'
    and excluido = 0
    and datareferencia >= DATEADD(DAY, -15, CAST(GETDATE() AS date));
GO
