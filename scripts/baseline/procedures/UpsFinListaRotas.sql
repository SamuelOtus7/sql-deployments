-- ============================================================
-- BASELINE: dbo.UpsFinListaRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UpsFinListaRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- SET ANSI_NULLS ON  
-- GO  
-- SET QUOTED_IDENTIFIER ON  
-- GO  
-- -- SET ANSI_NULLS ON  
-- -- GO  
-- -- SET QUOTED_IDENTIFIER ON  
-- GO  
CREATE procedure [dbo].[UpsFinListaRotas]   
  
(  
-- Filtros  
 @MarketPlace varchar   
,@transportadora int  
,@DataIni date   
,@DataFim date   
,@Motorista VARCHAR(120) = ''  
,@Status VARCHAR(120) = '' --em analise (se não passar, desconsidera)  
,@Base  VARCHAR(50) =  ''   
,@idorta VARCHAR(50) = ''   
,@skip int  
,@Take int  
) as  
  
  
  
  
-- -- Filtros  
-- declare @MarketPlace varchar = 'Mercado Livre'  
-- ,@transportadora int = 2087146923  
-- ,@DataIni date = '2024-02-16'  
-- ,@DataFim date = '2024-02-29'  
-- ,@Motorista VARCHAR(120) =  null  
-- ,@Status VARCHAR(120) = null --em analise (se não passar, desconsidera)  
-- ,@Base  VARCHAR(50) =  null   
-- ,@idorta VARCHAR(50) = null  
-- ,@Take int = 50   
-- ,@skip int = 60  
  
  
if len(@Motorista) = 0  
    set @Motorista = null  
  
if len(@Status) = 0  
    set @Status = null  
  
if len(@Base) = 0  
    set @Base = null  
  
if len(@idorta) = 0  
    set @idorta = null  
  
  
SELECT    
-- Top 1000  
      a.DataReferencia as data  
      ,a.IdRota  
      ,'Em Analise ' as StatusAnalise  
      ,a.ServiceCenter as Base  
      ,a.Motorista  
      ,a.QuantidadePacotes as Pacotes  
      ,a.PacotesEntregues as Sucessos  
      ,a.Insucessos as Insucessos  
      ,a.[CicloPM] as Ciclo  
      ,case when [CicloPM] = [CicloPMFatura] then 0 else 1 end FlagCicloDifPreFatura  
      ,a.[TipoVeiculo]  
      ,a.[TipoVeiculoCad] TipoVeiculoCadastrado   
      ,case when a.[TipoVeiculo] = a.[TipoVeiculoCad] then 0 else 1 end FlagVeiculoDifCadastrado --Validar  
      ,case when a.[TipoVeiculo] = a.[TipoVeiculoPreFatura] then 0 else 1 end FlagVeiculoDifPreFatura --Validar  
  
      ,a.UsouAPP  
      ,a.NumeroRota as QtdRotasMotorista  
        
      ,a.[KmColetado] as KmApp  
      ,a.[FaixaKm]    as FaixaKmApp  
      ,a.[KmColetado] as KmPacote --???????????????  
      ,a.[FaixaKm]    as FaixaKmPacote  
      ,a.[KmColetado] as KmTrevo --?????????????????????  
      ,a.[FaixaKm]    as FaixaKmTrevo  
        
      ,11654 as Apoio --????????????????????  
      ,case when rotas.Ambulancia = 1 then  'Sim' else 'Não' end as Ambulância  
    --   ,rotas.QuantidadeAmbulancia as Ambulância  
      ,case when PgtoAjudante > 0 then 1  else 0 end Ajudante  
      , pnr.QtdPnr PNR  
      , QuantidadeReclamacoes Reclamacao  
      , 1854 Sinistro --???????????????  
      , 20 AderenciaAoTrajeto --?????????????????  
  
  
  FROM [vw_resultado_financeiro] AS A  
  LEFT JOIN (  
                select   
                    pacotes.IdTransportadora  
                    ,pacotes.IdRota  
                    ,COUNT(*) QtdPnr  
  
                from vw_pacotes  as pacotes  
  
                inner join [dbo].[tb_ml_pnr] as BasePnr  
                on pacotes.IdTransportadora = BasePnr.IdTransportadora  
                and pacotes.identrega = BasePnr.IdPacote  
  
                where pacotes.IdTransportadora = @transportadora   
                and pacotes.DataReferencia BETWEEN @DataIni and @DataFim  
  
                GROUP BY pacotes.IdTransportadora ,pacotes.IdRota      
  ) as pnr  
  on a.IdRota = pnr.idrota  
  and  a.IdTransportadora = pnr.IdTransportadora  
  
left join vw_rotas as rotas  
on a.IdTransportadora = rotas.IdTransportadora  
and a.IdRota = rotas.IdRota  
  
  
  where 1=1  
--  @MarketPlace = 'Mercado Livre'  
and a.IdTransportadora = @transportadora  
AND a.DataReferencia BETWEEN @DataIni AND @DataFim   
AND ( @Motorista IS NULL OR Motorista =  @Motorista)  
  
AND (@Base IS NULL OR a.ServiceCenter = @Base)  
AND (@idorta IS NULL OR a.idrota = @idorta)  
order by a.idrota   
  
OFFSET @skip ROWS  
FETCH NEXT @Take ROWS ONLY;  
  
-- ,@Status VARCHAR(120) = null --em analise (se não passar, desconsidera)  
GO
