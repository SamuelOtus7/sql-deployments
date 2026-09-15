-- ============================================================
-- BASELINE: dbo.UspFinGeraPagamentoAdicional
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraPagamentoAdicional]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspFinGeraPagamentoAdicional]  (  
    @CodPeriodoPagamento int,  
 @idrota varchar(50) = null  
 --@avulso int = null -- codigo espelho,  
  
) as  
  
 declare   
      @IdTransportadora int   
    -- , @CodPeriodoPagamento int = 65  
    , @data_inicial date   
    , @data_final date   
 , @clienteid int  
 , @usuarioIrisys int  
 , @Motorista varchar(250)  
 , @IdCliTransportadora int  
 -- , @idrota varchar(50) = null  
    ,@tipocontrato int = null  
  
--, select * from tb_pgto_periodo  
--, where pgp_cd_cliente = 27  
  
   
  
 set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)  
 set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)  
  
   
  
 if @idrota is not null  
  begin   
   set @usuarioIrisys = (select distinct usuarioda from vw_rotas where idrota = @idrota)  
   set @Motorista = (select distinct NomeMotorista from vw_rotas where idrota = @idrota)  
  end  
   
 set @IdTransportadora = (  
       select cli_id_logistics  
       from [tb_pgto_periodo] as a  
       left join tb_clientes as b  
       on a.pgp_cd_cliente = cli_cd_codigo_cliente  
       where pgp_cd_periodo  = @CodPeriodoPagamento   
      )  
  
  
 set @IdCliTransportadora = (  
        
      select lst_cd_lista from tb_lista  
      where lst_nm_lista = 'Clientes transportadoras'  
      and lst_ds_label = 'Mercado Livre'  
      and lst_cd_cliente in (  
            select pgp_cd_cliente  
            from [tb_pgto_periodo] as a  
            left join tb_clientes as b  
            on a.pgp_cd_cliente = cli_cd_codigo_cliente  
            where pgp_cd_periodo  = @CodPeriodoPagamento  
            )  
            )  
         
  
  
 set @clienteid = (  
      select pgp_cd_cliente  
      from [tb_pgto_periodo] as a  
      left join tb_clientes as b  
      on a.pgp_cd_cliente = cli_cd_codigo_cliente  
      where pgp_cd_periodo  = @CodPeriodoPagamento   
      )  
  
  
 drop table if exists #tb_pgto_periodo_rota_edit   
 select *  
 into #tb_pgto_periodo_rota_edit  
 from(   
  select   
   *  
   ,cast(SUBSTRING(edit_Faixa_KM, 1, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(12,4)) as edit_km_selecionado  
   ,row_number() over(partition by edit_rota order by edit_dh_criacao desc) as ordem  
  
  from tb_pgto_periodo_rota_edit  
  --where (@idrota is null or edit_rota = @idrota)  
  
  ) as a  
 where ordem = 1;  
  
  
  
 drop table if exists #origem  
 select  
 *  
 into #origem  
 from  vw_rotas as a  
  
 where a.IdTransportadora = @IdTransportadora  
 and a.DataReferencia between @data_inicial and @data_final  
 and (@Motorista is null or a.NomeMotorista = @Motorista)  
    and (@idrota is null or a.idrota = @idrota)  
 and nomemotorista <> ''  
    -- and UsuarioDA in (  
    --                     select  
    --                     usr_cd_usuario  
    --                     from tb_usuario as a  
    --                     inner join tb_tipo_contrato as b  
    --                     on a.usr_cd_tipo_contrato = b.ttc_cd_tipo_contrato  
    --                     where cli_cd_codigo_cliente =   
    --                                             (  
    --                                             select pgp_cd_cliente  
 --            from [tb_pgto_periodo] as a  
 --            left join tb_clientes as b  
 --            on a.pgp_cd_cliente = cli_cd_codigo_cliente  
 --            where pgp_cd_periodo  = @CodPeriodoPagamento  
    --                                             )  
    --                     and (@clienteid in (37) OR a.usr_cd_tipo_contrato = @tipocontrato)  
    --                     )  
  
  
  
 drop table if exists #vw_rotas  
  select  distinct   
   a.*  
   ,cli_cd_codigo_cliente as IdTransportadoraClic  
   ,b.TipoVeiculo as TipoVeiculoAlterado  
   ,versaoapp.VersaoDA  
   ,VeiculoCad.vei_ds_tipo as TipoVeiculoCad  
  
  into #vw_rotas  
  
  from (  
    select   
     [IdTransportadora]  
  
  --   ,[Id]  
    ,a.[IdRota]  
    ,[DataReferencia]  
    ,[DataHoraInicio]  
    ,isnull(edit_Ciclo_PM,case when datepart(hour,DataHoraInicio) <= 12 then 'AM' else 'PM' end) Ciclo_Pm  
    ,[StatusRota]  
    ,[SubStatusRota]  
    ,[StatusPrazo]  
    ,isnull(edit_Service_Center,[ServiceCenter]) as ServiceCenter  
    ,[NomeServiceCenter]  
    ,[Base]  
    ,[CidadeBase]  
    ,[TipoOrigemSaida]  
    ,[OrigemSaida]  
    ,[TipoRota]  
    ,isnull(edit_Tipo_Veiculo,[TipoVeiculo]) as TipoVeiculo  
    ,[NomeMotorista]  
    ,isnull(edit_Placa,[Placa]) as Placa  
    ,[NivelExperienciaMotorista]  
    ,[IdNivelMotorista]  
    ,[NivelMotorista]  
    ,[QuantidadePacotesTransportados]  
    ,[PercentualEntregasBemSucedidas]  
    ,[PercentualEntregasSemRelamacaoes]  
    ,[PossuiAjudante]  
    ,[Ajudante]  
  
    ,isnull(cast([vmp_kmpagamento] as decimal(10,2)),  
  
    case   
   when IdTransportadora = 2087146923 and (base = LEFT([bkt_nm_cidades], CHARINDEX('- ', [bkt_nm_cidades]) - 1) or KmColetado = 0)  
    then 1  
   when IdTransportadora = 2087146923 and KmColetado > 0  
    then KmColetado   
   when IdTransportadora in (1726310024,643493085)  
    then case when KmColetadoMeli = 0 then 1 else KmColetadoMeli end  
   else  
    case when KmColetado = 0 then 1 else KmColetado end  end) KmColetado  
                  
    ,isnull(vmp_linkpagamento,  
    case   
     when IdTransportadora  in (1726310024,643493085)  
      then  LinkMapaMeli   
    else  
     LinkMapa  end ) LinkMapa  
  
  --   ,[LinkMapa]  
    ,[TotalPacotes]  
    ,[PacotesEntregues]  
    ,[PacotesPendentes]  
    ,[PacotesNaoEntregue]  
    ,[PacotesEntreguesForaAreaEntrega]  
    ,[PacotesTransferidos]  
    ,[TempoEmRota]  
    ,[TempoChegadaAreaEntrega]  
    ,[TempoAreaEntrega]  
    ,[PercentualProgresso]  
    ,[KmTotal]  
    ,[TempoEmRotaSec]  
    ,[SegundosEntreEntregas]  
    ,[RotaFinalizada]  
    ,[StatusGeralRota]  
  
    ,isnull(edit_Quantidade_Pontos,[QuantidadePontos]-[QuantidadeAmbulancia]-[PacotesTransferidos] ) as QuantidadePontos  
    ,isnull(edit_Quantidade_Paradas,[QuantidadeParadas]-[PacotesTransferidos]-PacotesNaoEntregue) as QuantidadeParadas  
  
    ,[QuantidadeReclamacoes]  
    ,[QuantidadeAmbulancia]  
    ,[StatusPrimeiraEntrega]  
    ,[StatusSegundaEntrega]  
    ,[DataUltimaEntrega]  
    ,[Cidades]  
    ,[CidadeReferencia]  
    ,[KmColetadoMeli]  
    ,[LinkMapaMeli]  
    ,[KmColetadoAPP]  
    ,[LinkMapaApp]  
    ,[Ambulancia]  
    ,[KmMotorista]  
    ,UsuarioDA  
    ,UsouAPP  
    ,idtrevo  
    ,case when (a.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário com Ajudante',  
            'Rental Utilitário com Ajudante')  
   or  
     a.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'  
     ,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35', 'EOC-8B83','GBL-0E72','STA4H72','FGF-8G96')  
       )  
    then 1  
    else null end Rental,  
  bkt_qt_cidades  
    
  from  #origem as a  
  
    left join #tb_pgto_periodo_rota_edit as b  
    on a.IdRota = b.edit_rota  
        
   left join tb_fin_base_km_trevo as trevo  
   on a.idtrevo = trevo.bkt_cd_base_km_trevo  
  
   left join [tb_validacao_mapas] as altermapa  
   on altermapa.vmp_cd_rota  = a.idrota  
  
   --where a.IdTransportadora = @IdTransportadora  
   --and a.DataReferencia between @data_inicial and @data_final  
   --and (@idrota is null or a.IdRota = @idrota)  
   --and a.tipo = 'last_mile'  
   ) as a  
      
  left join (  
     select a.*,b. cli_id_logistics   
     from tb_fin_resultado_financeiro_alteracao as a  
     inner join tb_clientes as b  
     on a.idtransportadora = b.cli_cd_codigo_cliente  
     ) as b  
  on a.IdTransportadora = b.cli_id_logistics  
  and a.idrota = b.idrota  
   
  left join   
  (  
    select   
     CodigoUsuario   
     ,NomeUsuario  
     ,VersaoDA  
  
    from [vw_dados_aparelhos]  
  
  ) as versaoapp  
  on a.NomeMotorista = versaoapp.NomeUsuario  
  
  left join (  
  
  SELECT    
   [vei_cd_veiculo]  
   ,[vei_cd_cliente]  
   ,[vei_ds_placa]  
   ,[vei_ds_tipo]  
  
   FROM [tb_veiculos] as a  
  
  ) as VeiculoCad  
  on a.Placa = VeiculoCad.vei_ds_placa  
  
  inner join  tb_clientes as cli  
  on a.idtransportadora  = cli.cli_id_logistics  
  
  where cli.cli_cd_codigo_cliente <> 7;  
  
  
  
update #vw_rotas   
 set   
  [IdTransportadora] = IdTransportadoraClic   
  
update a  
 set a.TipoVeiculo = b.tvl_cd_tipo_veiculo  
from #vw_rotas as a  
inner join tb_dra_tipo_veiculo as b  
on a.TipoVeiculo = b.tvl_nm_tipo_veiculo  
--------------------------------------------------------------------------------  
  
drop table if exists #tb_fin_pagamento_adicional   
create table #tb_fin_pagamento_adicional (  
 IdRota int,IdTransportadora int,DataReferencia date,FaixaParada decimal(10,2),FaixaPacote decimal(10,2)  
 ,vl_quantidade decimal(10,2), IdPeriodo int  
 );  
  
  
--insere parada quantidade  
insert #tb_fin_pagamento_adicional (IdRota,IdTransportadora,DataReferencia,vl_quantidade,IdPeriodo)  
select  
 a.IdRota   
 ,a.IdTransportadora   
 ,a.DataReferencia  
 ,b.valor as vl_quantidade  
 ,@CodPeriodoPagamento IdPeriodo  
from #vw_rotas  as a  
inner join tb_fin_base_frete_parametro_indicadores as b  
on a.idtransportadora = b.idtransportadora   
and a.ServiceCenter = b.ServiceCenter  
and a.TipoVeiculo = b.TipoVeiculo  
and cast(a.QuantidadeParadas as varchar(30)) = b.Faixa  
and (a.CidadeBase = b.Cidade or b.Cidade is null)  
and b.adicional = 'Parada'  
and a.idtransportadora in (19)  
  
-- calculo faixa de parada e faixa de pacote  
DECLARE @idrota_cursor INT;  
  
-- Declaração do cursor  
DECLARE rota_cursor CURSOR FOR  
SELECT DISTINCT idrota   
FROM #vw_rotas  
where idtransportadora in (27,34,11);  
  
OPEN rota_cursor;  
FETCH NEXT FROM rota_cursor INTO @idrota_cursor;  
  
-- Loop pelos registros  
WHILE @@FETCH_STATUS = 0  
BEGIN  
  
insert into #tb_fin_pagamento_adicional (IdRota,IdTransportadora,DataReferencia,FaixaParada,FaixaPacote,IdPeriodo)  
select *  
from (  
  
select   
  a.IdRota  
 ,a.IdTransportadora  
 ,a.DataReferencia  
 ,CASE   
  WHEN b.OrdemFaixa = 1 /*and a.QuantidadeParadas <= right(b.faixa,2)*/ then a.QuantidadeParadas * cast(replace(b.valor,',','.') as decimal(10,2))  
  WHEN b.OrdemFaixa = 2 and  (lag(replace(left(b.faixa,2),'-','')) OVER (ORDER BY OrdemFaixa)-1) > 0  
   then   
     (a.QuantidadeParadas- (a.QuantidadeParadas - left(b.faixa,2)+1)) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
    + (a.QuantidadeParadas - left(b.faixa,2)+1) * cast(replace(b.valor,',','.') as decimal(10,2))  
  
   WHEN b.OrdemFaixa = 3 and  (lag(replace(left(b.faixa,2),'-',''),2) OVER (ORDER BY OrdemFaixa)-1) > 0  
   then    
    ((lag(left(b.faixa,2)) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa))  
    +  
    ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2)) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
    +  
    (a.QuantidadeParadas - (lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa))) * cast(replace(b.valor,',','.') as decimal(10,2))  
  
  WHEN b.OrdemFaixa = 4 and  (lag(replace(left(b.faixa,2),'-',''),3) OVER (ORDER BY OrdemFaixa)-1) > 0  
   then    
    ((lag(left(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),3) OVER (ORDER BY OrdemFaixa))  
    +   
    ((lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa)  
    +  
    ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
    +  
    (a.QuantidadeParadas - right(b.faixa,2)) * cast(replace(b.valor,',','.') as decimal(10,2))  
  
  WHEN b.OrdemFaixa = 5 and  (lag(replace(left(b.faixa,2),'-',''),4) OVER (ORDER BY OrdemFaixa)-1) > 0  
   then  
    ((lag(left(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),4) OVER (ORDER BY OrdemFaixa))  
    +   
    ((lag(right(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),3) OVER (ORDER BY OrdemFaixa)  
    +  
    ((lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),3) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa)  
    +  
    ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
    +  
    (a.QuantidadeParadas - right(b.faixa,2)) * cast(replace(b.valor,',','.') as decimal(10,2))  
    
  ELSE 0 end  as FaixaParada  
     
 ,CASE   
   WHEN b.OrdemFaixa = 1 /*and a.PacotesEntregues <= right(b.faixa,2)*/ then a.PacotesEntregues * cast(replace(b.valor,',','.') as decimal(10,2))  
     
   WHEN b.OrdemFaixa = 2 and  (lag(replace(left(b.faixa,2),'-','')) OVER (ORDER BY OrdemFaixa)-1) > 0  
    then   
      (a.PacotesEntregues- (a.PacotesEntregues - left(b.faixa,2)+1)) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
     + (a.PacotesEntregues - left(b.faixa,2)+1) * cast(replace(b.valor,',','.') as decimal(10,2))  
  
   WHEN b.OrdemFaixa = 3 and  (lag(replace(left(b.faixa,2),'-',''),2) OVER (ORDER BY OrdemFaixa)-1) > 0  
     then    
     ((lag(left(b.faixa,2)) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa))  
     +  
     ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2)) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
     +  
     (a.PacotesEntregues - (lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa))) * cast(replace(b.valor,',','.') as decimal(10,2))  
  
   WHEN b.OrdemFaixa = 4 and  (lag(replace(left(b.faixa,2),'-',''),3) OVER (ORDER BY OrdemFaixa)-1) > 0  
     then    
     ((lag(left(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),3) OVER (ORDER BY OrdemFaixa))  
     +   
     ((lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa)  
     +  
     ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
   WHEN b.OrdemFaixa = 5 and  (lag(replace(left(b.faixa,2),'-',''),4) OVER (ORDER BY OrdemFaixa)-1) > 0  
    then  
     ((lag(left(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)-1) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),4) OVER (ORDER BY OrdemFaixa))  
     +   
     ((lag(right(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)) - (lag(left(b.faixa,2),3) OVER (ORDER BY OrdemFaixa)-1) ) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),3) OVER (ORDER BY OrdemFaixa)  
     +  
     ((lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),3) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2)),2) OVER (ORDER BY OrdemFaixa)  
     +  
     ((lag(right(b.faixa,2)) OVER (ORDER BY OrdemFaixa)+0) - (lag(right(b.faixa,2),2) OVER (ORDER BY OrdemFaixa))) * LAG(cast(replace(b.valor,',','.') as decimal(10,2))) OVER (ORDER BY OrdemFaixa)  
     +  
     (a.PacotesEntregues - right(b.faixa,2)) * cast(replace(b.valor,',','.') as decimal(10,2))  
     
   ELSE 0 end as FaixaPacote  
   ,@CodPeriodoPagamento IdPeriodo  
from #vw_rotas as a  
  
  
inner JOIN tb_fin_base_frete_parametro_indicadores as b  
  
on  a.idtransportadora = b.idtransportadora  
and (a.CidadeBase = b.Cidade or b.Cidade is null)  
and a.TipoVeiculo = b.TipoVeiculo  
and b.adicional = 'Parada'  
and a.ServiceCenter = b.ServiceCenter  
  
where 1=1  
and idrota = @idrota_cursor  
and  cast(REPLACE(b.Valor, ',','.') as decimal(10,2)) > 0  
  
) AS a  
where a.FaixaParada > 0  
;      
    -- Buscar o próximo registro  
    FETCH NEXT FROM rota_cursor INTO @idrota_cursor;  
END;  
  
-- Fechar e desalocar o cursor  
CLOSE rota_cursor;  
DEALLOCATE rota_cursor;  
  
  
--atualiza tabela de pagamento adicional  
MERGE INTO tb_fin_pagamento_adicional AS destino  
USING (  
    select   
    IdRota  
    ,IdTransportadora  
    ,DataReferencia  
    ,FaixaParada  
    ,FaixaPacote  
    ,coalesce(vl_parada,vl_quantidade) as vl_quantidade  
    ,IdPeriodo  
    from #tb_fin_pagamento_adicional as a  
    left join #tb_pgto_periodo_rota_edit as b  
    on a.idrota = b.edit_rota  
    ) AS origem  
ON destino.IdRota = origem.IdRota   
   AND destino.IdTransportadora = origem.IdTransportadora  
   AND destino.DataReferencia = origem.DataReferencia  
   and destino.IdPeriodo = origem.IdPeriodo  
WHEN MATCHED AND   
 (destino.FaixaParada <> origem.FaixaParada OR destino.FaixaPacote <> origem.FaixaPacote or destino.vl_quantidade <> origem.vl_quantidade) THEN  
    -- Atualiza os campos FaixaParada e FaixaPacote apenas se houver diferenças  
    UPDATE SET   
        destino.FaixaParada = origem.FaixaParada,  
        destino.FaixaPacote = origem.FaixaPacote,  
  destino.vl_quantidade = origem.vl_quantidade  
    
WHEN NOT MATCHED BY TARGET THEN  
    -- Insere os registros que não estão presentes na tabela de destino  
    INSERT (IdRota, IdTransportadora, DataReferencia, FaixaParada, FaixaPacote,vl_quantidade,IdPeriodo)  
    VALUES (origem.IdRota, origem.IdTransportadora, origem.DataReferencia, origem.FaixaParada, origem.FaixaPacote,vl_quantidade,IdPeriodo);  
  
  
UPDATE a  
SET a.ppr_vl_paradas = b.vl_quantidade  
,ppr_vl_total = (a.ppr_vl_base + b.vl_quantidade + a.ppr_vl_risco + a.ppr_vl_ajudante + a.ppr_vl_dom_fer + a.ppr_vl_lancamentos + ppr_vl_bonus)  
  
FROM tb_pgto_periodo_rota a  
INNER JOIN tb_fin_pagamento_adicional b  
ON a.ppr_cd_rota = b.IdRota  
AND a.ppr_cd_periodo = b.IdPeriodo  
AND a.ppr_cd_periodo = @CodPeriodoPagamento  
  
  
update a  
    set mtn_vl_nfs = total  
  
from tb_pag_espelhos a   
inner join (  
    select sum(ppr_vl_total) as total  
    ,ppr_cd_pgto_espelho  
    from tb_pgto_periodo_rota as a  
    where  ppr_cd_periodo = @CodPeriodoPagamento   
    group by ppr_cd_pgto_espelho  
) as b  
on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho   
  
GO
