-- ============================================================
-- BASELINE: dbo.UspMLAtualizaRotasRetroativo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLAtualizaRotasRetroativo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Saulo Barros
-- Create date: 14/07/2025
-- Description:  Reprocessa rotas com base no json de pacotes
-- =============================================
CREATE PROCEDURE [dbo].[UspMLAtualizaRotasRetroativo]
  @IdTransportadoraFiltro INT = NULL  -- NULL = todas; informado = só essa transportadora
AS
BEGIN
  SET NOCOUNT ON;

  -- Opcional: evitar execução silenciosa com ID inválido (ajuste se a tabela de cadastro for outra)
  -- IF @IdTransportadoraFiltro IS NOT NULL AND NOT EXISTS (
  --   SELECT 1 FROM tb_rotas_para_reprocessar WHERE IdTransportadora = @IdTransportadoraFiltro
  -- )
  -- BEGIN
  --   RAISERROR('Nenhuma rota na fila tb_rotas_para_reprocessar para esta transportadora.', 16, 1);
  --   RETURN;
  -- END

  drop table if exists #pacotes_json    
  select 
    cmr_cd_coleta,
    cmr_ds_json,  
    cast(cmr_cd_transportadora as int) cmr_cd_transportadora, 
    cmr_dh_referencia,
    cmr_dh_coleta,
    cast(cmr_cd_rota as int) cmr_cd_rota  
    ,ROW_NUMBER() over (partition by cmr_cd_transportadora, cmr_cd_rota order by cmr_cd_coleta desc) as rownum  
    into #pacotes_json  
  from  
    db_Irisys_Json.dbo.tb_ml_coleta_rotas c with(nolock)
    join tb_rotas_para_reprocessar r on c.cmr_cd_rota = r.Idrota 
                    and c.cmr_cd_transportadora = r.IdTransportadora
  where
    (@IdTransportadoraFiltro IS NULL OR c.cmr_cd_transportadora = @IdTransportadoraFiltro);

  delete from #pacotes_json where rownum > 1;


  drop table if exists #rotas
  SELECT 
    distinct
    aux.cmr_cd_rota AS IdRota
    ,aux.cmr_cd_transportadora AS IdTransportadora
    ,cast(null as date) DataReferencia
    ,aux.cmr_dh_referencia
    ,aux.cmr_dh_coleta DataHoraColeta
    ,case when DataHoraCriacao > 0 then cast(dateadd(second,((cast(DataHoraCriacao as bigint))) - 10800,'1970-01-01') as date) end DataCriacao
    ,case when DataHoraInicio > 0 then cast(dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') as date) end DataInicioRota
    ,case when DataHoraFim > 0 then dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataFimRota
    ,dateadd(second,((cast(DataHoraInicio as bigint))) - 10800,'1970-01-01') DataHoraInicio
    ,case when DataHoraFim > 0 then dateadd(second,((cast(DataHoraFim as bigint))) - 10800,'1970-01-01') end DataHoraFim
    ,ServiceCenter
    ,OrigemSaida
    ,TipoOrigemSaida
    ,StatusRota
    ,SubStatusRota
    ,StatusPrazo
    ,NomeMotorista
    ,Placa
    ,TipoVeiculo
    ,NivelExperienciaMotorista
    ,IdNivelMotorista
    ,NivelMotorista
    ,TipoRota
    ,Tipo
    ,TipoEntrega
    ,TempoEmRota
    ,TempoChegadaAreaEntrega
    ,TempoAreaEntrega
    ,isnull(TempoRetornoCentroDistribuicao,0) TempoRetornoCentroDistribuicao
    ,isnull(TotalPacotes,0) TotalPacotes
    ,isnull(PacotesEntregues,0) PacotesEntregues
    ,isnull(PacotesNaoEntregue,0) PacotesNaoEntregue
    ,isnull(PacotesPendentes,0) PacotesPendentes
    ,isnull(PacotesEntreguesForaAreaEntrega,0) PacotesEntreguesForaAreaEntrega
    ,isnull(PacotesTransferidos,0) PacotesTransferidos
    ,isnull(PacotesRecebidos,0) PacotesRecebidos
    ,isnull(TotalSacas,0) TotalSacas
    ,DriverId
    ,DriverUserId


    --Valores não encontrados no json
    ,null QuantidadeAmbulancia
    ,0 MotoristaArriscado
    ,null QuantidadeReclamacoesMotorista
    ,null TaxaDeContatoMotorista
    ,null QuantidadePacotesTransportados
    ,null PercentualEntregasBemSucedidas
    ,null PercentualEntregasSemRelamacaoes
    ,0 PossuiAjudante
    ,null TempoPlanejadoMinutos
    ,null PercentualProgresso
    ,null KmTotal
    ,null TempoInativo
    ,null QuantidadeReclamacoesFechadas
    ,null QuantidadeReclamacoesAbertas
    ,getdate() DataAtualizacao



    into #rotas
  FROM 
    #pacotes_json AS aux  
    CROSS APPLY OPENJSON(aux.cmr_ds_json)   
    WITH (
        DataHoraCriacao int '$.dateCreated'  
        ,DataHoraInicio int '$.initDate'  
        ,DataHoraFim int '$.finishDate'  
        ,ServiceCenter varchar(100) '$.serviceCenterId'
        ,OrigemSaida varchar(60) '$.destinationFacility.destinationFacilityId'
        ,TipoOrigemSaida varchar(50) '$.destinationFacility.destinationFacilityType'
        ,StatusRota varchar(50) '$.status'
        ,SubStatusRota varchar(50) '$.substatus'
        ,StatusPrazo varchar(30) '$.routePerformanceScore'
        ,NomeMotorista varchar(100) '$.driver.driverName'
        ,NivelExperienciaMotorista varchar(40) '$.driver.experience'
        ,IdNivelMotorista varchar(30) '$.driver.loyalty.id'
        ,NivelMotorista varchar(30) '$.driver.loyalty.name'
        ,Placa varchar(100) '$.license'
        ,TipoVeiculo varchar(100) '$.vehicleType'
        ,TipoRota varchar(100) '$.cluster'
        ,Tipo varchar(30) '$.type'
        ,TipoEntrega varchar(30) '$.deliveryType'
        ,TempoEmRota int '$.flags.orh'
        ,TempoChegadaAreaEntrega int '$.flags.stemOut'
        ,TempoAreaEntrega int '$.flags.ozh'
        ,TempoRetornoCentroDistribuicao int '$.flags.stemIn'
        ,TotalPacotes smallint '$.counters.totalShipments'
        ,PacotesEntregues smallint '$.counters.delivered'
        ,PacotesNaoEntregue smallint '$.counters.notDelivered'
        ,PacotesPendentes smallint '$.counters.pending'
        ,TotalSacas smallint '$.counters.totalBags'
        ,PacotesTransferidos smallint '$.counters.toRoutes'
        ,PacotesRecebidos smallint '$.counters.fromRoutes'
        ,PacotesEntreguesForaAreaEntrega smallint '$.outRangeDeliveryAmount'
        ,DriverId int '$.driverId'
        ,DriverUserId bigint '$.driver.driverUserId'

      )


  update 
    r
  set 
    DataReferencia = CASE
              WHEN prmData.prm_ds_valor = 1159 THEN isnull(DataInicioRota,DataCriacao)
              WHEN isnull(prmData.prm_ds_valor,1162) = 1162 THEN isnull(DataFimRota,cmr_dh_referencia)
            END
  from 
    #rotas r
    left join (
      SELECT
        cli.cli_id_logistics,
        prm_ds_valor
      FROM 
        tb_parametros AS a
        join tb_clientes AS cli ON cli.cli_cd_codigo_cliente = a.prm_cod_cliente
        inner join tb_lista AS lst ON a.prm_ds_valor = lst.lst_cd_lista
      WHERE 
        prm_nm_parametro = 'Data do Monitoramento'

    ) AS prmData ON prmData.cli_id_logistics = r.IdTransportadora


  --atualiza nome de motorista que veio nulo
  update #rotas set NomeMotorista = '' where NomeMotorista is null

  merge tb_ml_rotas as r
  using #rotas as i  ON r.IdRota = i.IdRota and r.IdTransportadora = i.IdTransportadora
  when matched then
  update set
    r.ServiceCenter = i.ServiceCenter
    ,r.OrigemSaida = i.OrigemSaida
    ,r.TipoOrigemSaida = i.TipoOrigemSaida
    ,r.Tipo = i.Tipo
    ,r.TipoRota = i.TipoRota
    ,r.StatusRota = i.StatusRota
    ,r.SubStatusRota = i.SubStatusRota
    ,r.TipoEntrega = i.TipoEntrega
    ,r.DataHoraInicio = i.DataHoraInicio
    ,r.DataHoraFim = i.DataHoraFim
    ,r.TotalPacotes = i.TotalPacotes
    ,r.PacotesEntregues = i.PacotesEntregues
    ,r.PacotesNaoEntregue = i.PacotesNaoEntregue
    ,r.PacotesPendentes = i.PacotesPendentes
    ,r.PacotesEntreguesForaAreaEntrega = i.PacotesEntreguesForaAreaEntrega
    ,r.PacotesTransferidos = i.PacotesTransferidos
    ,r.PacotesRecebidos = i.PacotesRecebidos
    ,r.TotalSacas = i.TotalSacas
    ,r.QuantidadeAmbulancia = i.QuantidadeAmbulancia
    ,r.StatusPrazo = i.StatusPrazo
    ,r.NomeMotorista = case when isnull(i.NomeMotorista ,'') <> '' then i.NomeMotorista else r.NomeMotorista end
    ,r.NivelExperienciaMotorista = i.NivelExperienciaMotorista
    ,r.MotoristaArriscado = i.MotoristaArriscado
    ,r.QuantidadeReclamacoesMotorista = i.QuantidadeReclamacoesMotorista
    ,r.TaxaDeContatoMotorista = i.TaxaDeContatoMotorista
    ,r.IdNivelMotorista = i.IdNivelMotorista
    ,r.NivelMotorista = i.NivelMotorista
    ,r.QuantidadePacotesTransportados = i.QuantidadePacotesTransportados
    ,r.PercentualEntregasBemSucedidas = i.PercentualEntregasBemSucedidas
    ,r.PercentualEntregasSemRelamacaoes = i.PercentualEntregasSemRelamacaoes
    ,r.PossuiAjudante = i.PossuiAjudante
    ,r.TipoVeiculo = i.TipoVeiculo
    ,r.Placa = i.Placa
    ,r.TempoPlanejadoMinutos = i.TempoPlanejadoMinutos
    ,r.PercentualProgresso = i.PercentualProgresso
    ,r.KmTotal = i.KmTotal
    ,r.TempoEmRota = i.TempoEmRota
    ,r.TempoChegadaAreaEntrega = i.TempoChegadaAreaEntrega
    ,r.TempoAreaEntrega = i.TempoAreaEntrega
    ,r.TempoRetornoCentroDistribuicao = i.TempoRetornoCentroDistribuicao
    ,r.TempoInativo = i.TempoInativo
    ,r.DataHoraColeta = i.DataHoraColeta
    ,r.DataAtualizacao = i.DataAtualizacao
    ,r.Excluido = 0
    ,r.DataCriacao = i.DataCriacao
    ,r.QuantidadeReclamacoesAbertas  = i.QuantidadeReclamacoesAbertas
    ,r.QuantidadeReclamacoesFechadas = i.QuantidadeReclamacoesFechadas
    ,r.DataInicioRota = i.DataInicioRota
    ,r.DataFimRota = i.DataFimRota
    ,r.datareferencia = i.DataReferencia
    ,r.DriverId = i.DriverId
    ,r.DriverUserId = i.DriverUserId

  when not matched by target then 
  insert (
      IdRota
      ,DataReferencia
      ,ServiceCenter
      ,OrigemSaida
      ,TipoOrigemSaida
      ,Tipo
      ,TipoRota
      ,StatusRota
      ,SubStatusRota
      ,TipoEntrega
      ,IdTransportadora
      ,DataHoraInicio
      ,DataHoraFim
      ,TotalPacotes
      ,PacotesEntregues
      ,PacotesNaoEntregue
      ,PacotesPendentes
      ,PacotesEntreguesForaAreaEntrega
      ,PacotesTransferidos
      ,PacotesRecebidos
      ,TotalSacas
      ,QuantidadeAmbulancia
      ,StatusPrazo
      ,NomeMotorista
      ,NivelExperienciaMotorista
      ,MotoristaArriscado
      ,QuantidadeReclamacoesMotorista
      ,TaxaDeContatoMotorista
      ,IdNivelMotorista
      ,NivelMotorista
      ,QuantidadePacotesTransportados
      ,PercentualEntregasBemSucedidas
      ,PercentualEntregasSemRelamacaoes
      ,PossuiAjudante
      ,TipoVeiculo
      ,Placa
      ,TempoPlanejadoMinutos
      ,PercentualProgresso
      ,KmTotal
      ,TempoEmRota
      ,TempoChegadaAreaEntrega
      ,TempoAreaEntrega
      ,TempoRetornoCentroDistribuicao
      ,TempoInativo
      ,DataHoraColeta
      ,DataAtualizacao
      ,Excluido
      ,DataCriacao
      ,QuantidadeReclamacoesAbertas 
      ,QuantidadeReclamacoesFechadas        
      ,IdTrevo
      ,DataInicioRota
      ,DataFimRota
      ,DriverId
      ,DriverUserId
  )
  values (
    i.IdRota
    ,i.DataReferencia
    ,i.ServiceCenter
    ,i.OrigemSaida
    ,i.TipoOrigemSaida
    ,i.Tipo
    ,i.TipoRota
    ,i.StatusRota
    ,i.SubStatusRota
    ,i.TipoEntrega
    ,i.IdTransportadora
    ,i.DataHoraInicio
    ,i.DataHoraFim
    ,i.TotalPacotes
    ,i.PacotesEntregues
    ,i.PacotesNaoEntregue
    ,i.PacotesPendentes
    ,i.PacotesEntreguesForaAreaEntrega
    ,i.PacotesTransferidos
    ,i.PacotesRecebidos
    ,i.TotalSacas
    ,i.QuantidadeAmbulancia
    ,i.StatusPrazo
    ,i.NomeMotorista
    ,i.NivelExperienciaMotorista
    ,i.MotoristaArriscado
    ,i.QuantidadeReclamacoesMotorista
    ,i.TaxaDeContatoMotorista
    ,i.IdNivelMotorista
    ,i.NivelMotorista
    ,i.QuantidadePacotesTransportados
    ,i.PercentualEntregasBemSucedidas
    ,i.PercentualEntregasSemRelamacaoes
    ,i.PossuiAjudante
    ,i.TipoVeiculo
    ,i.Placa
    ,i.TempoPlanejadoMinutos
    ,i.PercentualProgresso
    ,i.KmTotal
    ,i.TempoEmRota
    ,i.TempoChegadaAreaEntrega
    ,i.TempoAreaEntrega
    ,i.TempoRetornoCentroDistribuicao
    ,i.TempoInativo
    ,i.DataHoraColeta
    ,i.DataAtualizacao
    ,0
    ,i.DataCriacao
    ,i.QuantidadeReclamacoesAbertas
    ,i.QuantidadeReclamacoesFechadas    
    ,0 
    ,i.DataInicioRota
    ,i.DataFimRota
    ,i.DriverId
    ,i.DriverUserId
  );



  drop table if exists #indicadores_rotas
  select IdRota, IdTransportadora into #indicadores_rotas from #rotas

  while exists (select 1 from #indicadores_rotas)
  begin
    declare @IdRota int
    declare @IdTransportadora int

    select
      top 1
      @IdRota = IdRota
      ,@IdTransportadora = IdTransportadora
    from
      #indicadores_rotas

    exec UspMLAtualizaIndicadoresRota null, @IdRota, @IdTransportadora
    exec UspMLAtualizaDeltaIndicadoresRotas null, @IdRota, @IdTransportadora

    delete #indicadores_rotas where IdTransportadora = @IdTransportadora and IdRota = @IdRota
  end

  exec UspAtualzaUsuarioDA

end
GO
