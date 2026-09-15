-- ============================================================
-- BASELINE: dbo.vw_spe_painel_FM
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_painel_FM]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_spe_painel_FM]
 as 
     select r.Id,
    r.CodigoRota,
    r.IdTransportadora,
    r.DataReferencia,
    r.DataHoraInicio,
    r.DataHoraFim,
    r.DataHoraColeta,
    r.IdStation,
    r.IdMotorista,
    r.IdStatus,
    r.DataAtualizacao,
    r.Excluido,
    r.TotalPacotes,
    r.PacotesEntregues,
    r.PacotesNaoEntregue,
    r.PacotesPendentes,
    r.DataUltimaEntrega,
    r.KmColetado,
    r.LinkMapa,
    r.TipoVeiculo,
    r.DataHoraCarga,
    r.Paradas,
    r.CidadeReferencia,
    r.DistanciaTotal,
    r.UsuarioIrisys,
    r.KmApp,
    r.LinkMapaApp,
    r.QuantidadeApontamento,
    r.LinkAppInterno,
    r.Apuracao,
    r.UsouAPP,
    r.NomeHub,
    r.Motorista,
    r.placa,
    r.CidadeDistante,
    r.KmPacotes,
    r.LinkMapaPacotes,
    r.TipoOperacao,


    p.Id                AS IdPacote,
    p.IdWebhook,
    p.DataCriacaoRegistro,
    p.TipoJson,
    p.Agencia,
    p.IdTransportadora  AS IdTransportadoraPacote,
    p.CodigoTrace,
    p.CodigoRota        AS CodigoRotaPacote,
    p.CodigoPacote,
    p.StatusPacote,
    p.PickupPointId,
    p.DataHoraEvento,
    p.DataEventoUnix,
    p.DataCriacaoPacote,
    p.UltimoRegistro,
    p.Excluido          AS ExcluidoPacote,
    p.DataAtualizacao   AS DataAtualizacaoPacote,
    p.DataInclusao


from tb_spe_rotas_v5 R
inner join  tb_spe_pacotes_fm p on r.CODIGOROTA = p.CODIGOROTA AND p.IDTRANSPORTADORA = r.IDTRANSPORTADORA
 
where tipooperacao = 'FM'

GO
