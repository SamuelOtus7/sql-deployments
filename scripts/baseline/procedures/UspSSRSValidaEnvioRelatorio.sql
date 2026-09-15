-- ============================================================
-- BASELINE: dbo.UspSSRSValidaEnvioRelatorio
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSSRSValidaEnvioRelatorio]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSSRSValidaEnvioRelatorio]
(
    @IdRelatorio int,
    @IdTransportadora int,
    @Parametro1  varchar(2250) = '',
    @Parametro2  varchar(2250) = '',
    @Parametro3  varchar(2250) = '',
    @Parametro4  varchar(2250) = '',
    @Parametro5  varchar(2250) = '',
    @Parametro6  varchar(2250) = '',
    @Parametro7  varchar(2250) = '',
    @Parametro8  varchar(2250) = '',
    @Parametro9  varchar(2250) = '',
    @Parametro10 varchar(250) = ''
)
as


--declare     @IdRelatorio int = 1195,
--    @IdTransportadora int = 68,
--    @Parametro1  varchar(2250) = 'SRJ10',
--    @Parametro2  varchar(2250) = 'ambos',
--    @Parametro3  varchar(2250) = '',
--    @Parametro4  varchar(2250) = '',
--    @Parametro5  varchar(2250) = '',
--    @Parametro6  varchar(2250) = '',
--    @Parametro7  varchar(2250) = '',
--    @Parametro8  varchar(2250) = '',
--    @Parametro9  varchar(2250) = '',
--    @Parametro10 varchar(250) = ''

  --select top 10 *
  --  from tb_log_envios_relatorios nolock
  --where 1=1 
  --  and ler_ds_parametro1 = @Parametro1
  --  order by 1 desc

BEGIN



declare @QtdeRegistros int,
        @RelatorioFinalizado int,
        @Mensagem varchar(1000),
    @ultimaMensagem varchar(1000),
    @TeveEnvioHoje int,
    @idenvio int ,
    @TextoNaoTemDados varchar(1000) = 'Gostaríamos de informar, com a devida antecedência, não podemos fazer o envio deste relatório, pois ainda não há dados disponíveis para envio da base ' + @Parametro1 + '.' + 'Assim que a base possuir rotas disponíveis, as informações serão enviadas normalmente.'

drop table if exists #tablea_vlad_ml
create table #tablea_vlad_ml
(
IdTransportadora   varchar(50)
,NomeMotorista     varchar(100)
,servicecenter     varchar(50)
,OrigemSaida     varchar(50)
,idrota         varchar(50)
,ciclo         varchar(50)
,UltimaEntrega     varchar(50)
,TotalPacotes     varchar(50)
,PacotesEntregues   varchar(50)
,PacotesPendentes   varchar(50)
,Insucesso       varchar(50)
,PacotesTransferidos varchar(50)  
,Reclamacoes     varchar(50)
,RotaFinalizada     varchar(50)
,TotalRotas       varchar(50)
,RotaEmCurso     varchar(50)
,Progresso       varchar(50)
,StatusRota varchar(50)
,paradas  varchar(50)
,ORH varchar(50)
,OZH varchar(50)
,Stemout varchar(50)
,Placa varchar(50)
,PercentualPerformance varchar(50)
,DataHoraInicio varchar(50)
,[success_delivery] varchar(50)
,media_success_delivery varchar(50)
)


insert into #tablea_vlad_ml
exec sp_ssrs_ml_vld_monitoramento @Parametro2, @Parametro1, @IdTransportadora,@Parametro3


  select top 1 
  @ultimaMensagem = ler_ds_erro
  from tb_log_envios_relatorios nolock
  where 1=1 
    and ler_ds_parametro1 = @Parametro1
    and ler_cd_transportadora in (
                    select distinct  cli_id_logistics
                    from tb_clientes 
                    where 1=1 
                    and cli_cd_codigo_cliente =  @IdTransportadora
                    and cli_ds_logo_report  is not null
                    )

    and ler_cd_relatorio = @IdRelatorio
    and ler_dh_envio in (
              select max(ler_dh_envio)  
              from tb_log_envios_relatorios
              where 1=1 
              and ler_ds_parametro1 = @Parametro1
              and ler_cd_transportadora in (
                            select distinct  cli_id_logistics
                            from tb_clientes 
                            where 1=1 
                            and cli_cd_codigo_cliente =  @IdTransportadora
                            and cli_ds_logo_report  is not null
                        )
  and ler_cd_relatorio = @IdRelatorio)


select 
@TeveEnvioHoje = count(*)
from tb_log_envios_relatorios
where 1=1 
and ler_ds_status_envio = 'Enviar relatório'
and ler_cd_relatorio = @IdRelatorio
and cast(ler_dh_envio as date) = cast(getdate() as date)
and ler_cd_transportadora in (
                select distinct  cli_id_logistics
                from tb_clientes 
                where 1=1 
                and cli_cd_codigo_cliente =  @IdTransportadora
                and cli_ds_logo_report  is not null
                )
and ler_ds_parametro1 = @Parametro1



    select @RelatorioFinalizado = count(*)
    from tb_log_envios_relatorios
    where ler_cd_relatorio = @IdRelatorio
        and ler_cd_transportadora in (
                                        select distinct  cli_id_logistics
                                        from tb_clientes 
                                        where 1=1 
                                        and cli_cd_codigo_cliente =  @IdTransportadora
                                        and cli_ds_logo_report  is not null
                                        )
        and cast(ler_dh_envio as date) = cast(getdate() as date)
        and ler_in_finalizado = 1
        and ler_ds_status_envio = 'Sucesso'
        and ler_ds_parametro1 = @Parametro1
        and ler_ds_parametro2 = @Parametro2
        and ler_ds_parametro3 = @Parametro3
        and ler_ds_parametro4 = @Parametro4
        and ler_ds_parametro5 = @Parametro5
        and ler_ds_parametro6 = @Parametro6
        and ler_ds_parametro7 = @Parametro7
        and ler_ds_parametro8 = @Parametro8
        and ler_ds_parametro9 = @Parametro9
        and ler_ds_parametro10 = @Parametro10


IF @RelatorioFinalizado > 0
    BEGIN
        select 3 AS CodigoAcao,
            'Relatório não finalizado' AS DescricaoAcao,
            null as Mensagem
    END
ELSE
    BEGIN

        -- RESUMO SERVICE CENTER
        IF @idRelatorio in (1078,1107,1104,1101,1098)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_ml_resumo_svc
            where IdTransportadora = @IdTransportadora

            set @Mensagem = '*Resumo Service Center* - ' +  @TextoNaoTemDados

        END

    --novo resumo service center
        IF @idRelatorio in (1126,1160)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_ml_svc
            where IdTransportadora in (
                                        select distinct  cli_id_logistics
                                        from tb_clientes 
                                        where 1=1 
                                        and cli_cd_codigo_cliente =  @IdTransportadora
                                        and cli_ds_logo_report  is not null
                                        )

            set @Mensagem = '*Resumo Service Center* - ' +  @TextoNaoTemDados

        END


            -- RESUMO SERVICE CENTER spe
        IF @idRelatorio in (1127)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_spe_resumosvc 
            where IdTransportadora = @IdTransportadora

            set @Mensagem = '*Resumo Service Center* - ' +  @TextoNaoTemDados

        END

        -- RESUMO MOTORISTA
        ELSE IF @idRelatorio in  (1089,1106,1103,1100,1097)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_ml_resumo_svc_motorista
            where IdTransportadora =  @IdTransportadora
                and ServiceCenter = @Parametro1

            set @Mensagem = '*Resumo Motorista* - ' +  @TextoNaoTemDados

        END

        ELSE IF @idRelatorio in (1092, 1128,1128,1146,1151,

1180,
1181,
1182,
1183,
1186,
1187)
        BEGIN

            select @QtdeRegistros = count(*)
            from #tablea_vlad_ml 

            set @Mensagem = '*Resumo Monitoramento* - ' +  @TextoNaoTemDados
        END

        ELSE IF @idRelatorio in (1118,1122,1199,1184)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_spe_monitoramento
            where IdTransportadora in (
                        select distinct  cli_id_shopee
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @IdTransportadora
                        and cli_ds_logo_report  is not null
)
               -- and ServiceCenter = @Parametro1
        AND REPLACE(ServiceCenter, ' ', '_') = REPLACE(@Parametro1, ' ', '_')

                --OR Origemsaida = @Parametro1
            set @Mensagem = '*Resumo Monitoramento* - ' +  @TextoNaoTemDados

       -- END

        END

        ELSE IF @idRelatorio in (1195)
        BEGIN
            select @QtdeRegistros = count(*)
            from vw_ssrs_ml_monitoramento_decargo
            where IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @IdTransportadora
                        and cli_ds_logo_report  is not null
                )
               -- and ServiceCenter = @Parametro1
        AND REPLACE(ServiceCenter, ' ', '_') = REPLACE(@Parametro1, ' ', '_')

                --OR Origemsaida = @Parametro1
            set @Mensagem = '*Resumo Monitoramento* - ' +  @TextoNaoTemDados

       -- END

        END

set @idenvio = 
    case 
      when @QtdeRegistros > 0 then 1 
      when (@QtdeRegistros = 0 or @QtdeRegistros is null)
    --  and (@ultimaMensagem is null or @ultimaMensagem <> @Mensagem )
      then 2
      --when @QtdeRegistros = 0 and @ultimaMensagem is not null and  @ultimaMensagem <> @Mensagem  then 2
      else 3 end 

      select 
        @idenvio AS CodigoAcao,
        --@QtdeRegistros as registros,
        --@Mensagem as Mensagem,
        --@TeveEnvioHoje as TeveEnvioHoje,
        --@ultimaMensagem as ultimaMensagem,
        case when (@idenvio = 3 and @TeveEnvioHoje > 0) or  @ultimaMensagem = 'Não Envia'   then 'Não Envia' else case when @QtdeRegistros > 0 then 'Enviar relatório' else 'Enviar mensagem' end end AS DescricaoAcao,
        case when (@idenvio = 3 and @TeveEnvioHoje > 0) or  @ultimaMensagem = 'Não Envia'   then null else case when @QtdeRegistros > 0 then null else @Mensagem end end as Mensagem    

    END
END

 
GO
