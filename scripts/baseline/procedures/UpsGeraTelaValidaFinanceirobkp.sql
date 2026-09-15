-- ============================================================
-- BASELINE: dbo.UpsGeraTelaValidaFinanceirobkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UpsGeraTelaValidaFinanceirobkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   procedure [dbo].[UpsGeraTelaValidaFinanceirobkp]   
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
--  declare @MarketPlace varchar = 'Mercado Livre'  
--  ,@transportadora int = 2087146923  
--  ,@DataIni date = '2024-08-01'  
--  ,@DataFim date = '2024-08-15'  
--  ,@Motorista VARCHAR(120) =  null  
--  ,@Status VARCHAR(120) = 'Em análise' --em analise (se não passar, desconsidera)  
--  ,@Base  VARCHAR(50) =  'EGO11'   
--  ,@idorta VARCHAR(50) = null  
--  ,@Take int = 50   
--  ,@skip int = 60  
  
  
 DECLARE @Transportadoraid INT =  (SELECT cli_cd_codigo_cliente  FROM tb_clientes WHERE cli_id_logistics = @transportadora AND cli_cd_codigo_cliente <> 7)  
  
if len(@Motorista) = 0  
    set @Motorista = null  
  
if len(@Status) = 0  
begin  
    set @Status = null  
END  
else if @Status = 'Em análise'  
begin  
    set @Status = null  
end   
  
if len(@Base) = 0  
    set @Base = null  
  
if len(@idorta) = 0  
    set @idorta = null  
  
  
SELECT    
-- Top 1000  
      a.DataReferencia as data  
      ,a.IdRota  
    --   ,listas_validacoes.lst_ds_valor  
      ,isnull(listas_validacoes.lst_ds_valor,'Em análise') as StatusAnalise  
      ,case when a.ServiceCenter <> a.XPT then a.xpt else a.ServiceCenter end  as Base  
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
        
      ,0 as Apoio --????????????????????  
      ,case when rotas.Ambulancia = 1 then  'Sim' else 'Não' end as Ambulância  
    --   ,rotas.QuantidadeAmbulancia as Ambulância  
      ,case when PgtoAjudante > 0 then 'Sim'  else 'Não' end Ajudante  
      , pnr.QtdPnr PNR  
      , QuantidadeReclamacoes Reclamacao  
      , 0 Sinistro --???????????????  
      , 0 AderenciaAoTrajeto --?????????????????  
   --,Ajudante  
   ,LancRisco as Risco  
   ,Observacao  
   ,Destino as Cidade  
   ,A.QuantidadeParadas  
   ,Regiao  
   ,RiscoV2  
   ,ISNULL(AjudanteV2,case when PgtoAjudante > 0 then 'Sim'  else 'Não' end ) as AjudanteV2  
   ,DividiuRota  
   ,IdMotoristaDividiuRota 
   ,A.QuantidadePontos as QuantidadePontos
   ,rotas.tipo as Operacao
  
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
  
                where pacotes.IdTransportadora = @Transportadoraid   
                and pacotes.DataReferencia BETWEEN @DataIni and @DataFim  
  
                GROUP BY pacotes.IdTransportadora ,pacotes.IdRota      
  ) as pnr  
  on a.IdRota = pnr.idrota  
  and  a.cli_id_logistics = pnr.IdTransportadora  
  
left join vw_rotas as rotas  
on a.cli_id_logistics = rotas.IdTransportadora  
and a.IdRota = rotas.IdRota  
  
-- left join tb_validacao_rotas as validacoes  
-- on a.IdRota = validacoes.vrt_cd_status_validacao  
  
left join (  
            SELECT [vrt_cd_rota] idrota  
                ,[vrt_cd_status_validacao]  
                ,[vrt_cd_usuario_validacao]  
                ,[vrt_dt_data_hora_validacao]  
                ,lst_ds_valor  
                ,ROW_NUMBER() OVER (PARTITION BY vrt_cd_rota ORDER BY [vrt_dt_data_hora_validacao] DESC) as rn  
  
            FROM [tb_validacao_rotas] as a  
            left join tb_lista as b  
            on a.vrt_cd_status_validacao = b.lst_cd_lista  
  
            where lst_nm_lista = 'Status Validacao Rotas'  
) as listas_validacoes  
on a.idrota = listas_validacoes.idrota  
  
  where 1=1  
--  @MarketPlace = 'Mercado Livre'  
and a.IdTransportadora = @Transportadoraid  
AND a.DataReferencia BETWEEN @DataIni AND @DataFim   
AND ( @Motorista IS NULL OR Motorista =  @Motorista)  
  
AND (@Base IS NULL OR a.ServiceCenter = @Base OR a.xpt = @base)  
AND (@idorta IS NULL OR a.idrota = @idorta)  
and (@Status is null or listas_validacoes.lst_ds_valor = @Status )  
order by a.idrota   
  
OFFSET @skip ROWS  
FETCH NEXT @Take ROWS ONLY;  
  
-- ,@Status VARCHAR(120) = null --em analise (se não passar, desconsidera) 
GO
