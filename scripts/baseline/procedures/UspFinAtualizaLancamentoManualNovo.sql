-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualNovo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualNovo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UspFinAtualizaLancamentoManualNovo] (    
    @CodPeriodoPagamento VARCHAR(50),    
    @idrota VARCHAR(50) = NULL    
    ) AS    
  
 declare    
   @IdTransportadora int    
 --, @CodPeriodoPagamento int = 2592
 --, @idrota varchar(50) = null    
 , @data_inicial date    
 , @data_final date    
 , @clienteid int    
 , @usuarioIrisys int    
 , @Motorista varchar(250)    
 , @IdCliTransportadora int    
 , @tipocontrato int = null    
 , @Operacao int
      

      
      
 set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with (nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)  
 set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with (nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)  
   
  
 set @IdCliTransportadora = (  
  
      select lst_cd_lista from tb_lista (NOLOCK)  
      where lst_nm_lista = 'Clientes transportadoras'  
      and lst_ds_label = 'Mercado Livre'  
      and lst_cd_cliente in (  
            select pgp_cd_cliente  
            from [tb_pgto_periodo] as a (NOLOCK)  
            left join tb_clientes as b (NOLOCK)  
            on a.pgp_cd_cliente = cli_cd_codigo_cliente  
            where pgp_cd_periodo  = @CodPeriodoPagamento  
            )  
        )  
  
 set @clienteid = (  
      select pgp_cd_cliente  
      from [tb_pgto_periodo] as a (NOLOCK)  
      left join tb_clientes as b (NOLOCK)  
      on a.pgp_cd_cliente = cli_cd_codigo_cliente  
      where pgp_cd_periodo  = @CodPeriodoPagamento  
      )  


 set @Operacao = (  
      select pgp_tipo_operacao  
      from [tb_pgto_periodo] as a (NOLOCK)  
      left join tb_clientes as b (NOLOCK)  
      on a.pgp_cd_cliente = cli_cd_codigo_cliente  
      where pgp_cd_periodo  = @CodPeriodoPagamento  
      ) 


    declare @UtilizaSVC int = (
        select  prm_ds_valor
        from    tb_parametros as p
        where   prm_nm_parametro like 'Service Center Padrão'
                and prm_cod_cliente = @clienteid 
    )

    set @UtilizaSVC = isnull(@UtilizaSVC,'0')
  


  /* ======================  
       #Lancamentos Cancelados
       ====================== */    
  --3 cenarios
    --Casos com rota do periodo - Deve zerar o valor do lançamento e remover o vinculo do lancamento manual (cd_lanc)
    --Casos com rota de periodos anteriores - Deve deletar o registro
    --Casos sem rota - deve deletar o registro


----Casos de lançamentos indevidos e cancelados com rota 
update  a
set     ppr_vl_end_nvisitado = 0
    ,   ppr_vl_pct_perdido = 0
    ,   ppr_vl_pnr = 0
    ,   ppr_vl_lancamentos_rotas = 0

    ,   ppr_dh_modificacao = getdate()
    ,   ppr_cd_usr_modificacao = 7
from    tb_pgto_periodo_rota as a
        left join tb_pgto_rotas_lanc_manuais as cod
            on a.ppr_lcto_cd_lancamento = plm_cd_lancamentos
        left join vw_lancamentos_manuais_reprovados as lan
            on cod.plm_cd_rota = lan.tlm_cd_rota
            and a.ppr_base_principal = lan.tlm_cd_service_center
        join tb_pag_espelhos e 
            on a.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
            and e.mtn_cd_status in (34,228,38,1298)   

where   ppr_cd_periodo = @CodPeriodoPagamento
        and ppr_lcto_cd_lancamento is not null
        and ppr_cd_rota is not null
        and lan.tlm_cd_lancamento_manual is not null
        and ppr_in_excluido = 0
        and ppr_nm_pgto = 'Rota Mercado Livre'
       



--Casos com rota de periodos anteriores ou apoio
update  a
set     ppr_in_excluido = 1
    ,   ppr_dh_modificacao = getdate()
    ,   ppr_cd_usr_modificacao = 7
from  tb_pgto_periodo_rota as a
       
       join tb_pag_espelhos e 
            on a.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
            and e.mtn_cd_status in (34,228,38,1298)   

       join tb_pgto_rotas_lanc_manuais as cod
            on a.ppr_lcto_cd_lancamento = cod.plm_cd_lancamentos
            --and a.ppr_cd_motorista_nfs = cod.plm_cd_espelhos
            and a.ppr_cd_rota = cod.plm_cd_rota
    join vw_lancamentos_manuais_reprovados as lan
        on cod.plm_cd_rota = lan.tlm_cd_rota
        and a.ppr_nome_motorista = isnull(lan.tlm_ds_motorista_apoio,lan.tlm_cd_motorista)
            and a.ppr_base_principal = lan.tlm_cd_service_center

where   ppr_cd_periodo = @CodPeriodoPagamento
        and ppr_lcto_cd_lancamento is not null
        and ppr_cd_rota is not null
        and lan.tlm_cd_lancamento_manual is not null
        and ppr_in_excluido = 0
        and ppr_nm_pgto = 'Manual'




--Casos de lançamentos indevidos e cancelados sem rota 
update  a
set     ppr_in_excluido = 1
    ,   ppr_dh_modificacao = getdate()
    ,   ppr_cd_usr_modificacao = 7
from    tb_pgto_periodo_rota as a
        left join tb_pgto_rotas_lanc_manuais as cod
            on a.ppr_lcto_cd_lancamento = plm_cd_lancamentos
        left join vw_lancamentos_manuais_aprovados as lan
        on cod.plm_cd_lancamento = lan.tlm_cd_lancamento_manual
        and a.ppr_base_principal = lan.tlm_cd_service_center
        join tb_pag_espelhos e 
            on a.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			and e.mtn_cd_status in (34,228,38,1298)  

where  ppr_cd_periodo = @CodPeriodoPagamento
    and ppr_lcto_cd_lancamento is not null
    and ppr_cd_rota is null
    and lan.tlm_cd_lancamento_manual is null
    and ppr_in_excluido = 0





    /* ======================  
       #Lancamentos (temp)  
       ====================== */  
    DROP TABLE IF EXISTS #Lancamentos;  
    SELECT  
          @CodPeriodoPagamento                       AS Periodo  
        , CAST(a.tlm_dh_referencia AS date)          AS Data 
        , a.tlm_cd_service_center
        , 0 considerar_svc
        , a.tlm_cd_lancamento_manual  
        , case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end tlm_ds_observacao
        , case when a.tlm_cd_rota = 'null' or a.tlm_cd_rota = '' then null else a.tlm_cd_rota end  as tlm_cd_rota  
        , a.plm_nm_tipo  
        , a.tlm_cd_motorista  
        , a.tlm_ds_motorista_apoio 
        , a.tlm_cd_mot
        , a.tlm_cd_mot_apoio
        , a.tlm_tipo_valor_apoio
        , a.tlm_ds_valor_referencia
        ,  ISNULL(a.tlm_vl_valor_descontos, 0) * -1      AS tlm_vl_valor_descontos  
        ,  ISNULL(a.tlm_vl_valor_adicional, 0)       AS tlm_vl_valor_adicional  
        ,  ISNULL(a.tlm_vl_valor_rota, 0)            AS tlm_vl_valor_rota  
        ,  ISNULL(a.tlm_vl_valor_apoio, 0)   * -1          AS tlm_vl_valor_apoio  
    INTO #Lancamentos  
    FROM dbo.vw_lancamentos_manuais_aprovados AS a WITH (NOLOCK)  
    WHERE a.tlm_cd_cliente      = @ClienteId  
      AND a.tlm_dh_referencia  >= @data_inicial  
      AND a.tlm_dh_referencia  <  DATEADD(DAY, 1, @Data_Final)  
      ;  
    
    CREATE INDEX IX_Lancamentos ON #Lancamentos (tlm_cd_rota, tlm_cd_motorista, Data);  



	------------------------------------------------------------
	-- ATUALIZA VALOR DOS LANÇAMENTOS APOIO EM PERCENTUAL
	------------------------------------------------------------
	update
		l
	set
		l.tlm_vl_valor_apoio =  case when abs(l.tlm_vl_valor_apoio) > 100 then 1.00 else abs(l.tlm_vl_valor_apoio) / 100.00 end 
								* 
								case when l.tlm_ds_valor_referencia = 'Total' then p.ppr_vl_total - isnull(p.ppr_vl_lancamentos,0) else p.ppr_vl_base end
                                * -1
    from    #Lancamentos as l
    join    tb_pgto_periodo_rota p on l.tlm_cd_rota = p.ppr_cd_rota
							    and p.ppr_cd_tipo_pgto = 1362
							    and p.ppr_in_excluido = 0
							    and p.ppr_cd_periodo = @CodPeriodoPagamento
    join    tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
										    and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
										    and e.mtn_cd_operacao = @Operacao
    where   plm_nm_tipo = 'Apoio'
            and tlm_tipo_valor_apoio = 'Percentual' 
		    and tlm_cd_rota is not null



    /* ==========================================  
       Corrige bases de lançamentos anteriores para a 
        base do espelho do motorista na quinzena atual
       ========================================== */  

    update  a
    set     tlm_cd_service_center = mtn_base_principal
        ,   considerar_svc = 1
    from    #Lancamentos as a
    inner   join (
                select  mtn_driver_id , mtn_nome_motorista , count(mtn_base_principal) bases
                from    tb_pag_espelhos as a
                where   mtn_cd_pgto_periodo = @CodPeriodoPagamento
                group   by mtn_driver_id , mtn_nome_motorista
                having  count(mtn_base_principal) = 1

                ) as b on a.tlm_cd_motorista = b.mtn_nome_motorista
    inner   join tb_pag_espelhos as c on a.tlm_cd_motorista = c.mtn_nome_motorista and a.tlm_cd_service_center <> c.mtn_base_principal
    where   c.mtn_cd_pgto_periodo = @CodPeriodoPagamento
            and plm_nm_tipo like '%PF%'
            and tlm_cd_service_center not in ('UBÁ','EAGLE')

  
    /* ==========================================  
       #LancamentosAgregados (somente com rota)  
       ========================================== */  
      
    DROP TABLE IF EXISTS #LancamentosAgregados;  
    select   
     mtn_cd_motorista_nfs ppr_cd_motorista_nfs  
    ,tlm_cd_rota  
    ,tlm_ds_observacao
    ,vl_valor 
    ,tlm_apoiador
    ,0 as ppr_vl_pnr
    ,0 as ppr_vl_pct_perdido
    ,0 as ppr_vl_end_nvisitado

    into  #LancamentosAgregados  

    from   
    (  
            SELECT
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
                l.tlm_cd_mot,
                --coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center) ServiceCenter,
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @UtilizaSVC <> 1 then r.OrigemSaida else r.ServiceCenter end end,tlm_cd_service_center) ServiceCenter,
                STRING_AGG(l.tlm_ds_observacao, ' || ') AS tlm_ds_observacao,
                SUM(l.tlm_vl_valor_descontos
                  + l.tlm_vl_valor_adicional
                  + l.tlm_vl_valor_rota
                  + l.tlm_vl_valor_apoio) AS vl_valor,
                  0 tlm_apoiador
            FROM #Lancamentos AS l
            left join tb_ml_rotas as r with(nolock)
                on l.tlm_cd_rota = cast(r.IdRota as varchar(max))
            left join tb_bases as bss
                on r.origemsaida = bss.bss_ds_sigla and r.IdTransportadora = bss.bss_cd_idtransportadora and bss.bss_espelho_xpt = 1

            where plm_nm_tipo NOT LIKE '%PF%'
            --and l.tlm_cd_rota =  '333697911	'
            GROUP BY
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
                l.tlm_cd_mot,
                --coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center)
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @UtilizaSVC <> 1 then r.OrigemSaida else r.ServiceCenter end end,tlm_cd_service_center)
     
     
            union all

            SELECT
                l.tlm_cd_rota,
                l.tlm_ds_motorista_apoio,
                l.tlm_cd_mot_apoio,
                --coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center) ServiceCenter,
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @UtilizaSVC <> 1 then r.OrigemSaida else r.ServiceCenter end end,tlm_cd_service_center) ServiceCenter,
                STRING_AGG(l.tlm_ds_observacao, ' || ') AS tlm_ds_observacao,
                SUM(l.tlm_vl_valor_descontos
                  + l.tlm_vl_valor_adicional
                  + l.tlm_vl_valor_rota
                  + l.tlm_vl_valor_apoio) AS vl_valor,
                  1 tlm_apoiador
            FROM #Lancamentos AS l
            left join tb_ml_rotas as r with(nolock)
                on l.tlm_cd_rota = cast(r.IdRota as varchar(max))
            left join tb_bases as bss
                on r.origemsaida = bss.bss_ds_sigla and r.IdTransportadora = bss.bss_cd_idtransportadora and bss.bss_espelho_xpt = 1

            where plm_nm_tipo NOT LIKE '%PF%'
            --and l.tlm_cd_rota =  '333697911	
            and l.tlm_ds_motorista_apoio is not null
            GROUP BY
                l.tlm_cd_rota,
                l.tlm_ds_motorista_apoio,
                l.tlm_cd_mot_apoio,
                --coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center)
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and @UtilizaSVC <> 1 then r.OrigemSaida else r.ServiceCenter end end,tlm_cd_service_center)
     
     
     ) as l  
     left JOIN dbo.tb_pag_espelhos AS pr WITH (NOLOCK)  
           -- ON pr.mtn_nome_motorista    = l.tlm_cd_motorista  
           ON (
                  (l.tlm_cd_mot is null and pr.mtn_nome_motorista = l.tlm_cd_motorista)
                or
                  (l.tlm_cd_mot is not null and pr.mtn_cd_motorista = l.tlm_cd_mot)

                )
           AND pr.mtn_cd_pgto_periodo   = @CodPeriodoPagamento
           and (pr.mtn_base_principal   = l.ServiceCenter or l.ServiceCenter is null)
           and pr.mtn_in_excluido = 0
           --and l.tlm_cd_rota =  '335030571'
  




    DROP TABLE IF EXISTS #LancamentosAgregadosPF;
    select   
         mtn_cd_motorista_nfs ppr_cd_motorista_nfs  
        ,tlm_cd_rota  
        ,tlm_ds_observacao
        ,vl_valor  
        ,ppr_vl_pnr
        ,ppr_vl_pct_perdido
        ,ppr_vl_end_nvisitado

    into  #LancamentosAgregadosPF  

    from   
    (  
            SELECT
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
                l.tlm_cd_mot,
                STRING_AGG(l.tlm_ds_observacao, ' || ') AS tlm_ds_observacao,
                SUM(l.tlm_vl_valor_descontos
                  + l.tlm_vl_valor_adicional
                  + l.tlm_vl_valor_rota
                  + l.tlm_vl_valor_apoio) AS vl_valor
                ,sum(case when tlm_ds_observacao like '%pnr%' then l.tlm_vl_valor_descontos else null end)             as ppr_vl_pnr
                ,sum(case when tlm_ds_observacao like '%lost%' then l.tlm_vl_valor_descontos else null end)              as ppr_vl_pct_perdido
                ,sum(case when tlm_ds_observacao like '%Daily Not Visited%' then l.tlm_vl_valor_descontos else null end) as ppr_vl_end_nvisitado
                --,case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.origemsaida then r.origemsaida else r.servicecenter end  end ServiceCenter
                ,coalesce(veiculo.vei_ds_base_espelho,case when considerar_svc = 1 then tlm_cd_service_center
                    else
                    case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and 1 <> 1 then r.OrigemSaida else r.ServiceCenter end end
                    end) ServiceCenter

            FROM #Lancamentos AS l
            left join tb_ml_rotas as r with(nolock)
                on l.tlm_cd_rota = r.IdRota
            left join tb_bases as bss
                on r.origemsaida = bss.bss_ds_sigla and r.IdTransportadora = bss.bss_cd_idtransportadora and bss.bss_espelho_xpt = 1
            left join (
                select
                    cli_id_logistics,a.*
                from tb_veiculos as a (NOLOCK)
                inner join tb_clientes as b (NOLOCK)
                    on a.vei_cd_cliente = b.cli_cd_codigo_cliente
                    and a.vei_in_ativo = 1
            ) as veiculo
                on r.idtransportadora = veiculo.cli_id_logistics
                and r.Placa = veiculo.vei_ds_placa

            where plm_nm_tipo LIKE '%PF%'
            --and tlm_cd_rota = '333743005'
            GROUP BY
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
                l.tlm_cd_mot,
               --case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.origemsaida then r.origemsaida else r.servicecenter end  end
                coalesce(veiculo.vei_ds_base_espelho,case when considerar_svc = 1 then tlm_cd_service_center
                    else
                    case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.OrigemSaida and left(r.OrigemSaida,1) in ('E','M') and 1 <> 1 then r.OrigemSaida else r.ServiceCenter end end
                    end)
     ) as l  
     JOIN dbo.tb_pag_espelhos AS pr WITH (NOLOCK)  
             --ON pr.mtn_nome_motorista    = l.tlm_cd_motorista 
            ON (
                  (l.tlm_cd_mot is null and pr.mtn_nome_motorista = l.tlm_cd_motorista)
                or
                  (l.tlm_cd_mot is not null and pr.mtn_cd_motorista = l.tlm_cd_mot)

                )
           and (pr.mtn_base_principal   = l.ServiceCenter or l.ServiceCenter is null)
           AND pr.mtn_cd_pgto_periodo   = @CodPeriodoPagamento  
           and pr.mtn_in_excluido       = 0
           --and l.tlm_cd_rota = '333743005'  
  
    
    CREATE INDEX IX_LancAgreg ON #LancamentosAgregadosPF (tlm_cd_rota, ppr_cd_motorista_nfs);  
          
  
          
    /* ============================================================  
       1) Mapeia espelho ? rota (lançamentos com rota)  
       ============================================================ */  
    INSERT INTO dbo.tb_pgto_rotas_lanc_manuais (plm_cd_espelhos, plm_cd_rota)  
    SELECT  a.ppr_cd_motorista_nfs,  
            a.tlm_cd_rota  
    FROM (
            select ppr_cd_motorista_nfs, tlm_cd_rota from #LancamentosAgregados 
            union all
            select ppr_cd_motorista_nfs, tlm_cd_rota from #LancamentosAgregadosPF
    )AS a  
    WHERE NOT EXISTS (  
        SELECT 1  
        FROM dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
        WHERE m.plm_cd_espelhos = a.ppr_cd_motorista_nfs  
          AND m.plm_cd_rota     = a.tlm_cd_rota  
    )  
    and a.ppr_cd_motorista_nfs is  NOT null   ;  
  
    /* ============================================================  
       2) Mapeia espelho ? lançamento (lançamentos sem rota)  
       ============================================================ */  
    INSERT INTO dbo.tb_pgto_rotas_lanc_manuais (plm_cd_espelhos, plm_cd_lancamento)  
    SELECT  e.mtn_cd_motorista_nfs,  
            l.tlm_cd_lancamento_manual  
    FROM #Lancamentos AS l  
    INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)  
             --ON e.mtn_nome_motorista  = l.tlm_cd_motorista  
            ON (
                  (l.tlm_cd_mot is null and e.mtn_nome_motorista = l.tlm_cd_motorista)
                or
                  (l.tlm_cd_mot is not null and e.mtn_cd_motorista = l.tlm_cd_mot)

                )  
           AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento  
    WHERE (l.tlm_cd_rota IS NULL )  
      AND NOT EXISTS (  
            SELECT 1  
            FROM dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
            WHERE m.plm_cd_espelhos   = e.mtn_cd_motorista_nfs  
              AND m.plm_cd_lancamento = l.tlm_cd_lancamento_manual  
      );  
  
     /* ============================================================  
       2) Mapeia espelho ? lançamento (lançamentos com rota, porem de quinzenas anteriores)  
       ============================================================ */  
   INSERT INTO dbo.tb_pgto_rotas_lanc_manuais (plm_cd_espelhos, plm_cd_lancamento)  
   SELECT  e.mtn_cd_motorista_nfs,  
            L.tlm_cd_lancamento_manual  
    FROM #LancamentosAgregados AS a  
    INNER JOIN #Lancamentos l  
    on A.tlm_cd_rota = L.tlm_cd_rota  
    INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)  
            --ON e.mtn_nome_motorista  = l.tlm_cd_motorista  
            ON (
                  (l.tlm_cd_mot is null and e.mtn_nome_motorista = l.tlm_cd_motorista)
                or
                  (l.tlm_cd_mot is not null and e.mtn_cd_motorista = l.tlm_cd_mot)

                )
           AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento  
    WHERE (A.ppr_cd_motorista_nfs IS NULL )  
      AND NOT EXISTS (  
            SELECT 1  
            FROM dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
            WHERE m.plm_cd_espelhos   = e.mtn_cd_motorista_nfs  
              AND m.plm_cd_lancamento = l.tlm_cd_lancamento_manual  
      );   
  
    --select  * from #LancamentosAgregados where tlm_cd_rota  = '296528471'  
    --select  * from #Lancamentos where tlm_cd_rota  = '296528471'  
      
    /* ============================================================  
       3) Atualiza valores agregados nas rotas do período  
          (e vincula o lançamento quando existir no mapa)  
       ============================================================ */  
  
    update tb_pgto_periodo_rota 
    set ppr_lcto_cd_lancamento = null
    where ppr_Cd_periodo = @CodPeriodoPagamento
    and ppr_in_excluido = 1
  


    UPDATE pr  
       SET pr.ppr_vl_lancamentos_rotas = ag.vl_valor  
       ,pr.ppr_lcto_cd_lancamento = plm_cd_lancamentos  
      
    FROM dbo.tb_pgto_periodo_rota AS pr  
    INNER JOIN #LancamentosAgregados AS ag  
            ON pr.ppr_cd_rota         = ag.tlm_cd_rota  
           AND pr.ppr_cd_motorista_nfs= ag.ppr_cd_motorista_nfs  
    JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
            ON m.plm_cd_rota          = ag.tlm_cd_rota  
           AND m.plm_cd_espelhos      = ag.ppr_cd_motorista_nfs 
           --AND m.plm_cd_lancamentos = pr.ppr_lcto_cd_lancamento  
    JOIN dbo.tb_pag_espelhos as e
            ON pr.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
    WHERE pr.ppr_cd_periodo = @CodPeriodoPagamento  
        and pr.ppr_vl_periodo_anterior is null
        and pr.ppr_in_excluido = 0 
        AND e.mtn_cd_status IN (34,228,38)
        and ag.tlm_apoiador = 0

    --and  plm_cd_lancamentos = 3997  
  




    /* ============================================================  
       4) Insere créditos de APOIO (com rota)  
       ============================================================ */  
    MERGE INTO dbo.tb_pgto_periodo_rota AS target
    USING (
        SELECT
              l.tlm_cd_rota                             AS ppr_cd_rota
            , e.mtn_nome_motorista                      AS ppr_nome_motorista
            , l.Data                                    AS ppr_data_referencia
            , l.tlm_ds_observacao                       AS ppr_lcto_observacao
            , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_apoio
            , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_total
            , @CodPeriodoPagamento                      AS ppr_cd_periodo
            , e.mtn_cd_motorista_nfs                    AS ppr_cd_pgto_espelho
            , GETDATE()                                 AS ppr_dh_criacao
            , 7                                         AS ppr_cd_usr_criacao
            , GETDATE()                                 AS ppr_dh_modificacao
            , 7                                         AS ppr_cd_usr_modificacao
            , 1                                         AS ppr_in_ativo
            , 0                                         AS ppr_in_excluido
            , e.mtn_cd_motorista                        AS ppr_cd_motorista
            , e.mtn_cd_motorista_nfs                    AS ppr_cd_motorista_nfs
            , e.mtn_base_principal                      AS ppr_base_principal
            , m.plm_cd_lancamentos                      AS ppr_lcto_cd_lancamento
            , 1363                                      AS ppr_cd_tipo_pgto
            , 'Manual'                                  AS ppr_nm_pgto
            , e.mtn_driver_id                           AS ppr_driver_id
        FROM #Lancamentos AS l
        INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)
               --ON e.mtn_nome_motorista  = l.tlm_ds_motorista_apoio
            ON (
                  (l.tlm_cd_mot_apoio is null and e.mtn_nome_motorista = l.tlm_ds_motorista_apoio)
                or
                  (l.tlm_cd_mot_apoio is not null and e.mtn_cd_motorista = l.tlm_cd_mot_apoio)

                )
              AND e.mtn_base_principal = l.tlm_cd_service_center
              AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento

        --INNER JOIN dbo.tb_pag_espelhos AS e2 WITH (NOLOCK)  
        --        --ON e2.mtn_nome_motorista  = l.tlm_cd_motorista 
        --    ON (
        --          (l.tlm_cd_mot is null and e2.mtn_nome_motorista = l.tlm_cd_motorista)
        --        or
        --          (l.tlm_cd_mot is not null and e2.mtn_cd_motorista = l.tlm_cd_mot)

        --        ) 
        --      and e2.mtn_base_principal = l.tlm_cd_service_center
        --      AND e2.mtn_cd_pgto_periodo = @CodPeriodoPagamento  

        LEFT JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)
               ON m.plm_cd_rota = l.tlm_cd_rota
              AND m.plm_cd_espelhos = e.mtn_cd_motorista_nfs

        WHERE l.plm_nm_tipo = 'Apoio'
          AND e.mtn_cd_status IN (34,228,38)
          AND l.tlm_cd_rota IS NOT NULL
    ) AS source
    ON target.ppr_cd_periodo      = source.ppr_cd_periodo
   AND target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho
   AND target.ppr_cd_rota         = source.ppr_cd_rota
   AND target.ppr_data_referencia = source.ppr_data_referencia
   --AND target.ppr_lcto_observacao = source.ppr_lcto_observacao
   AND target.ppr_base_principal  = source.ppr_base_principal
   AND target.ppr_lcto_cd_lancamento  = source.ppr_lcto_cd_lancamento
   AND target.ppr_in_excluido     = 0

    WHEN MATCHED THEN
        UPDATE SET
              target.ppr_vl_apoio            = source.ppr_vl_apoio
            , target.ppr_vl_total            = source.ppr_vl_total
            , target.ppr_lcto_cd_lancamento  = source.ppr_lcto_cd_lancamento
            , target.ppr_dh_modificacao      = GETDATE()
            , target.ppr_cd_usr_modificacao  = 7

    WHEN NOT MATCHED THEN
        INSERT (
              ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao
            , ppr_vl_apoio, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho
            , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao
            , ppr_in_ativo, ppr_in_excluido
            , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal, ppr_lcto_cd_lancamento
            , ppr_cd_tipo_pgto, ppr_nm_pgto, ppr_driver_id
        )
        VALUES (
              source.ppr_cd_rota, source.ppr_nome_motorista, source.ppr_data_referencia, source.ppr_lcto_observacao
            , source.ppr_vl_apoio, source.ppr_vl_total, source.ppr_cd_periodo, source.ppr_cd_pgto_espelho
            , source.ppr_dh_criacao, source.ppr_cd_usr_criacao, source.ppr_dh_modificacao, source.ppr_cd_usr_modificacao
            , source.ppr_in_ativo, source.ppr_in_excluido
            , source.ppr_cd_motorista, source.ppr_cd_motorista_nfs, source.ppr_base_principal, source.ppr_lcto_cd_lancamento
            , source.ppr_cd_tipo_pgto, source.ppr_nm_pgto, source.ppr_driver_id
        );






  --  INSERT INTO dbo.tb_pgto_periodo_rota  
  --      ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao  
  --      , ppr_vl_apoio, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
  --      , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao  
  --      , ppr_in_ativo, ppr_in_excluido  
  --      , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal ,ppr_lcto_cd_lancamento
		--, ppr_cd_tipo_pgto,ppr_nm_pgto,ppr_driver_id)  

  --  SELECT  
  --        l.tlm_cd_rota                             AS ppr_cd_rota  
  --      , l.tlm_ds_motorista_apoio                  AS ppr_nome_motorista  
  --      , l.Data                                    AS ppr_data_referencia  
  --      , l.tlm_ds_observacao                       AS ppr_lcto_observacao  
  --      , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_apoio  
  --      , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_total  
  --      , @CodPeriodoPagamento                      AS ppr_cd_periodo  
  --      , e.mtn_cd_motorista_nfs                    AS ppr_cd_pgto_espelho  
  --      , GETDATE()                                 as ppr_dh_criacao  
  --      , 7                                         as ppr_cd_usr_criacao  
  --      , GETDATE()                                 as ppr_dh_modificacao  
  --      , 7                                         as ppr_cd_usr_modificacao  
  --      , 1                                         as ppr_in_ativo  
  --      , 0                                         as ppr_in_excluido  
  --      , e.mtn_cd_motorista                        AS ppr_cd_motorista  
  --      , e.mtn_cd_motorista_nfs                    AS ppr_cd_motorista_nfs  
  --      , e.mtn_base_principal                      AS ppr_base_principal  
  --      , m.plm_cd_lancamentos                      AS ppr_lcto_cd_lancamento  
		--, 1363										AS ppr_cd_tipo_pgto
  --      , 'Manual'                                  as ppr_nm_pgto
  --      , e.mtn_driver_id                           as ppr_driver_id
  
  --  FROM #Lancamentos AS l  

  --  INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)  
  --         ON e.mtn_nome_motorista  = l.tlm_ds_motorista_apoio 
  --         and e.mtn_base_principal = l.tlm_cd_service_center
  --         AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento  

  --  INNER JOIN dbo.tb_pag_espelhos AS e2 WITH (NOLOCK)  
  --         ON e2.mtn_nome_motorista  = l.tlm_cd_motorista 
  --         and e2.mtn_base_principal = l.tlm_cd_service_center
  --         AND e2.mtn_cd_pgto_periodo = @CodPeriodoPagamento  

  --  LEFT  JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
  --         ON m.plm_cd_rota         = l.tlm_cd_rota  
  --         AND m.plm_cd_espelhos     = e2.mtn_cd_motorista_nfs  

  --  WHERE l.plm_nm_tipo = 'Apoio'  
  --    AND e.mtn_cd_status IN (34,228,38)
  --    and l.tlm_cd_rota is not null
  --    AND NOT EXISTS (  
  --          SELECT 1  
  --          FROM dbo.tb_pgto_periodo_rota AS pr WITH (NOLOCK)  
  --          WHERE pr.ppr_cd_periodo      = 2604  
  --            AND pr.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs  
  --            AND pr.ppr_cd_rota         = l.tlm_cd_rota  
  --            AND pr.ppr_data_referencia = l.Data  
  --            AND pr.ppr_lcto_observacao = l.tlm_ds_observacao  
  --            AND pr.ppr_base_principal  = l.tlm_cd_service_center  
  --            and pr.ppr_in_excluido = 0
  --    )

      --and l.tlm_cd_rota = '341039217'
      ;  
  

 --select *  from #LancamentosAgregadosPF where tlm_cd_rota = 326624026

    /* ============================================================  
       5) Insere as rotas dos periodos anteriores   
       ============================================================ */  
MERGE INTO dbo.tb_pgto_periodo_rota AS target
USING (
   
   SELECT 
          cast(m.plm_cd_rota as varchar(50))                                    AS ppr_cd_rota
        , e.mtn_nome_motorista                                                  AS ppr_nome_motorista
        , @data_inicial                                                         AS ppr_data_referencia
        , STRING_AGG(l.tlm_ds_observacao, ' || ')                               AS ppr_lcto_observacao
        , sum(case when tipo = 'Manual'  then vl_valor else null end)           AS ppr_vl_periodo_anterior
        , @CodPeriodoPagamento                                                  AS ppr_cd_periodo
        , e.mtn_cd_motorista_nfs                                                AS ppr_cd_pgto_espelho
        , GETDATE()                                                             AS ppr_dh_criacao
        , 7                                                                     AS ppr_cd_usr_criacao
        , GETDATE()                                                             AS ppr_dh_modificacao
        , 7                                                                     AS ppr_cd_usr_modificacao
        , 1                                                                     AS ppr_in_ativo
        , 0                                                                     AS ppr_in_excluido
        , e.mtn_cd_motorista                                                    AS ppr_cd_motorista
        , e.mtn_cd_motorista_nfs                                                AS ppr_cd_motorista_nfs
        , e.mtn_base_principal                                                  AS ppr_base_principal
        , m.plm_cd_lancamentos                                                  AS ppr_lcto_cd_lancamento
        , 1363                                                                  AS ppr_cd_tipo_pgto
        , sum(l.ppr_vl_pnr)                                                     AS ppr_vl_pnr
        , sum(l.ppr_vl_pct_perdido)												AS ppr_vl_pct_perdido
        , sum(l.ppr_vl_end_nvisitado)											AS ppr_vl_end_nvisitado
        , 'Manual'                                                              as ppr_nm_pgto
        , e.mtn_driver_id                                                       as ppr_driver_id

   FROM (

       
            select 
                 ppr_cd_motorista_nfs	
                ,cast(tlm_cd_rota as varchar(50)) as tlm_cd_rota
                ,tlm_ds_observacao	
                ,vl_valor	
                ,'Manual' AS tipo 
                ,'0.0'ppr_vl_pnr	
                ,'0.0'ppr_vl_pct_perdido	
                ,'0.0'ppr_vl_end_nvisitado
                ,DataReferencia
            from #LancamentosAgregados as a
            inner join tb_ml_rotas as r
            on cast(idrota as varchar(50)) = tlm_cd_rota 
            and excluido = 0
            and statusrota <> 'planned'

            union all

            select 
                 ppr_cd_motorista_nfs
                ,cast(tlm_cd_rota as varchar(50)) as tlm_cd_rota
                ,tlm_ds_observacao
                ,vl_valor
                , 'PF'  AS tipo
                ,ppr_vl_pnr
                ,ppr_vl_pct_perdido
                ,ppr_vl_end_nvisitado
                ,DataReferencia
            from #LancamentosAgregadosPF as a 
            inner join tb_ml_rotas as r
            on cast(idrota as varchar(50)) = tlm_cd_rota
            and excluido = 0
            and statusrota <> 'planned'
            
            ) as l
    left join(   
    
        select b.DataReferencia , a.*  
        from tb_pgto_periodo_rota as a
        inner  join tb_ml_rotas as b with(nolock) on a.ppr_cd_rota = cast(b.idRota as varchar(max))
        where ppr_cd_periodo = @CodPeriodoPagamento
        and a.ppr_data_referencia = b.DataReferencia 
             and excluido = 0
        and statusrota <> 'planned'
        
    )as r  
    on r.ppr_cd_motorista_nfs = l.ppr_cd_motorista_nfs    
    and tlm_cd_rota = r.ppr_cd_rota  

    JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)
         ON m.plm_cd_rota = l.tlm_cd_rota
        AND l.ppr_cd_motorista_nfs = m.plm_cd_espelhos
    JOIN tb_pag_espelhos AS e
         ON l.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs

    --join vw_lancamentos_manuais_aprovados as lanc  
    --    on m.plm_cd_rota = lanc.tlm_cd_rota  
    
    WHERE e.mtn_cd_status IN (34,228,38)
        and  r.ppr_cd_rota is null  
        and l.DataReferencia not between @data_inicial and @data_final

        --and plm_nm_tipo not like '%PF%'
	group by
		cast(m.plm_cd_rota as varchar(50))
        , e.mtn_nome_motorista
        , e.mtn_cd_motorista_nfs
        , e.mtn_cd_motorista
        , e.mtn_cd_motorista_nfs
        , e.mtn_base_principal
        , m.plm_cd_lancamentos
        , e.mtn_driver_id

) AS source
ON target.ppr_cd_periodo = source.ppr_cd_periodo
   AND target.ppr_cd_rota = source.ppr_cd_rota
   AND target.ppr_lcto_cd_lancamento = source.ppr_lcto_cd_lancamento
   AND target.ppr_cd_motorista_nfs   = source.ppr_cd_motorista_nfs

WHEN MATCHED THEN
    UPDATE SET 
          target.ppr_vl_periodo_anterior   = source.ppr_vl_periodo_anterior
        , target.ppr_lcto_observacao  = source.ppr_lcto_observacao
        , target.ppr_cd_motorista     = source.ppr_cd_motorista
        , target.ppr_cd_usr_modificacao = 7
        , target.ppr_dh_modificacao   = GETDATE()
        , target.ppr_nm_pgto          = source.ppr_nm_pgto
        , target.ppr_vl_pnr           = source.ppr_vl_pnr                                                          
        , target.ppr_vl_pct_perdido   = source.ppr_vl_pct_perdido   
        , target.ppr_vl_end_nvisitado = source.ppr_vl_end_nvisitado 
        , target.ppr_driver_id        = source.ppr_driver_id 


WHEN NOT MATCHED THEN
    INSERT (
          ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao
        , ppr_vl_periodo_anterior, ppr_cd_periodo, ppr_cd_pgto_espelho
        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao
        , ppr_in_ativo, ppr_in_excluido
        , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal, ppr_lcto_cd_lancamento
        , ppr_cd_tipo_pgto, ppr_nm_pgto, ppr_vl_pnr, ppr_vl_pct_perdido   , ppr_vl_end_nvisitado
        , ppr_driver_id
    )
    VALUES (
          source.ppr_cd_rota, source.ppr_nome_motorista, source.ppr_data_referencia, source.ppr_lcto_observacao
        , source.ppr_vl_periodo_anterior, source.ppr_cd_periodo, source.ppr_cd_pgto_espelho
        , source.ppr_dh_criacao, source.ppr_cd_usr_criacao, source.ppr_dh_modificacao, source.ppr_cd_usr_modificacao
        , source.ppr_in_ativo, source.ppr_in_excluido
        , source.ppr_cd_motorista, source.ppr_cd_motorista_nfs, source.ppr_base_principal, source.ppr_lcto_cd_lancamento
        , source.ppr_cd_tipo_pgto, source.ppr_nm_pgto, source.ppr_vl_pnr, source.ppr_vl_pct_perdido   , source.ppr_vl_end_nvisitado 
        , source.ppr_driver_id

    );



  --  INSERT INTO dbo.tb_pgto_periodo_rota  
  --      ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao  
  --      , ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
  --      , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao  
  --      , ppr_in_ativo, ppr_in_excluido  
  --      , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal ,ppr_lcto_cd_lancamento, ppr_cd_tipo_pgto )  
      
  --    SELECT  
  --        m.plm_cd_rota                                           AS ppr_cd_rota  
  --      , e.mtn_nome_motorista                                    AS ppr_nome_motorista  
  --      , @data_inicial                                           AS ppr_data_referencia  
  --      , null                                                  AS ppr_lcto_observacao  
  --      , (vl_valor) AS ppr_vl_lancamentos  
  --      , (vl_valor) AS ppr_vl_total  
  --      , @CodPeriodoPagamento                                  AS ppr_cd_periodo  
  --      , e.mtn_cd_motorista_nfs                                AS ppr_cd_pgto_espelho  
  --      , GETDATE()                                             as ppr_dh_criacao  
  --      , 7                                                     as ppr_cd_usr_criacao  
  --      , GETDATE()                                             as ppr_dh_modificacao  
  --      , 7                                                     as ppr_cd_usr_modificacao  
  --      , 1                                                     as ppr_in_ativo  
  --      , 0                                                     as ppr_in_excluido  
  --      , e.mtn_cd_motorista                                    AS ppr_cd_motorista  
  --      , e.mtn_cd_motorista_nfs                                AS ppr_cd_motorista_nfs  
  --      , e.mtn_base_principal                                  AS ppr_base_principal  
  --      , m.plm_cd_lancamentos                                  as ppr_lcto_cd_lancamento  
		--, 1363													as ppr_cd_tipo_pgto
  
  --  from  #LancamentosAgregados  l  
      
  --  left join(   
    
  --  select a.*  
  --  from tb_pgto_periodo_rota as a
  --  inner  join tb_ml_rotas as b with(nolock) on a.ppr_cd_rota = b.idRota
  --  where ppr_cd_periodo = @CodPeriodoPagamento 
  --      and a.ppr_data_referencia = b.DataReferencia 

  --  )as r  
  --  on r.ppr_cd_motorista_nfs = l.ppr_cd_motorista_nfs    
  --  and tlm_cd_rota = r.ppr_cd_rota  
  
  --  join   dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
  --  ON m.plm_cd_rota = l.tlm_cd_rota  
  --  and l.ppr_cd_motorista_nfs = m.plm_cd_espelhos  
  
  --  join tb_pag_espelhos as e  
  --  on l.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs  
  
  --  where 1=1  
  --  AND e.mtn_cd_status IN (34,228,38) 
  --  and  r.ppr_cd_rota is null  
  
  
    /* ============================================================  
       6) Insere lançamentos SEM ROTA  
       ============================================================ */  
MERGE INTO dbo.tb_pgto_periodo_rota AS target
USING (
    SELECT 
          NULL                                                  AS ppr_cd_rota
        , e.mtn_nome_motorista                                  AS ppr_nome_motorista
        , l.Data                                                AS ppr_data_referencia
        , l.tlm_ds_observacao                                   AS ppr_lcto_observacao
        , (l.tlm_vl_valor_descontos 
                + l.tlm_vl_valor_adicional
                + l.tlm_vl_valor_rota)                          AS ppr_vl_sem_rota
        , @CodPeriodoPagamento                                  AS ppr_cd_periodo
        , e.mtn_cd_motorista_nfs                                AS ppr_cd_pgto_espelho
        , GETDATE()                                             AS ppr_dh_criacao
        , 7                                                     AS ppr_cd_usr_criacao
        , GETDATE()                                             AS ppr_dh_modificacao
        , 7                                                     AS ppr_cd_usr_modificacao
        , 1                                                     AS ppr_in_ativo
        , 0                                                     AS ppr_in_excluido
        , e.mtn_cd_motorista                                    AS ppr_cd_motorista
        , e.mtn_cd_motorista_nfs                                AS ppr_cd_motorista_nfs
        , e.mtn_base_principal                                  AS ppr_base_principal
        , m.plm_cd_lancamentos                                  AS ppr_lcto_cd_lancamento
        , 1363                                                  AS ppr_cd_tipo_pgto
        , 'Manual'                                              as ppr_nm_pgto
        
   FROM #Lancamentos AS l
    INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)
            --ON e.mtn_nome_motorista  = l.tlm_cd_motorista
            ON (
                  (l.tlm_cd_mot is null and e.mtn_nome_motorista = l.tlm_cd_motorista)
                or
                  (l.tlm_cd_mot is not null and e.mtn_cd_motorista = l.tlm_cd_mot)

                )
           AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
           and e.mtn_base_principal = l.tlm_cd_service_center
    INNER JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)
            ON m.plm_cd_lancamento = l.tlm_cd_lancamento_manual
            and e.mtn_cd_motorista_nfs = m.plm_cd_espelhos
    WHERE l.tlm_cd_rota IS NULL
      AND e.mtn_cd_status IN (34,228,38)

) AS source
ON target.ppr_cd_periodo = source.ppr_cd_periodo
   AND target.ppr_lcto_cd_lancamento = source.ppr_lcto_cd_lancamento
   and target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs
   and target.ppr_base_principal   = source.ppr_base_principal

WHEN MATCHED THEN
    UPDATE SET 
          target.ppr_lcto_observacao  = source.ppr_lcto_observacao
        , target.ppr_vl_sem_rota      = source.ppr_vl_sem_rota
        , target.ppr_dh_modificacao   = GETDATE()
        , target.ppr_cd_usr_modificacao = 7
        , target.ppr_nm_pgto          = source.ppr_nm_pgto

WHEN NOT MATCHED THEN
    INSERT (
          ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao
        , ppr_vl_sem_rota, ppr_cd_periodo, ppr_cd_pgto_espelho
        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao
        , ppr_in_ativo, ppr_in_excluido
        , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal, ppr_lcto_cd_lancamento
        , ppr_cd_tipo_pgto, ppr_nm_pgto
    )
    VALUES (
          source.ppr_cd_rota, source.ppr_nome_motorista, source.ppr_data_referencia, source.ppr_lcto_observacao
        , source.ppr_vl_sem_rota, source.ppr_cd_periodo, source.ppr_cd_pgto_espelho
        , source.ppr_dh_criacao, source.ppr_cd_usr_criacao, source.ppr_dh_modificacao, source.ppr_cd_usr_modificacao
        , source.ppr_in_ativo, source.ppr_in_excluido
        , source.ppr_cd_motorista, source.ppr_cd_motorista_nfs, source.ppr_base_principal, source.ppr_lcto_cd_lancamento
        , source.ppr_cd_tipo_pgto,source.ppr_nm_pgto
    );
  
  
  
/* ---------------------------  
   identifica os lancamentos cancelados  
   --------------------------- */  
DROP TABLE IF EXISTS #LctosAtuais;  
  
select   
    m.plm_cd_lancamentos  
,   m.plm_cd_rota

INTO #LctosAtuais  
  
from tb_pgto_rotas_lanc_manuais as m  
  
inner join tb_pag_espelhos as b  
on b.mtn_cd_motorista_nfs = m.plm_cd_espelhos  
  
left JOIN #Lancamentos  l WITH (NOLOCK)  
ON m.plm_cd_lancamento = l.tlm_cd_lancamento_manual  
  
where mtn_cd_pgto_periodo = @CodPeriodoPagamento   
and plm_cd_rota is null  
and l.tlm_cd_lancamento_manual is null  
  
union   
  
select   
    m.plm_cd_lancamentos  
,   m.plm_cd_rota
from tb_pgto_rotas_lanc_manuais as m  
  
inner join tb_pag_espelhos as b  
on b.mtn_cd_motorista_nfs = m.plm_cd_espelhos  
  
left JOIN #Lancamentos  l WITH (NOLOCK)  
ON l.tlm_cd_rota = m.plm_cd_rota  
  
where mtn_cd_pgto_periodo = @CodPeriodoPagamento   
and plm_cd_lancamento is NULL  
and l.tlm_cd_rota  is null  
  
  
  
/* Opcional: índice para acelerar o join */  
CREATE INDEX IX_LctosAtuais ON #LctosAtuais (plm_cd_lancamentos);  
  
  
/* ---------------------------  
   B) Soft delete — por lançamento (APOIO + SEM ROTA)  
   --------------------------- */  
   /*
UPDATE pr  
   SET pr.ppr_in_excluido        = 1,  
       pr.ppr_dh_modificacao     = GETDATE(), -- getdate precisa ser uma variavel unica no codigo  
       pr.ppr_cd_usr_modificacao = 7 --apos a atualizaco do irisys incluir o usuario deve alterar este campo para uma variabel  
 
FROM dbo.tb_pgto_periodo_rota pr  
  
JOIN #LctosAtuais la  
       ON la.plm_cd_lancamentos = pr.ppr_lcto_cd_lancamento 
       and la.plm_cd_rota is null
  
WHERE pr.ppr_cd_periodo = @CodPeriodoPagamento  
  AND pr.ppr_in_excluido = 0  
 */ 


/* ---------------------------  
B) Soft delete — por lançamento (APOIO + COM ROTA)  
Casos cancelados com rota devem se manter no espelho com o valor de base frete
--------------------------- */  
/*
update  pr
set     ppr_vl_lancamentos = null
    ,   ppr_lcto_cd_lancamento = null
    ,   ppr_vl_total = 0
    ,   pr.ppr_dh_modificacao     = GETDATE()   -- getdate precisa ser uma variavel unica no codigo  
    ,   pr.ppr_cd_usr_modificacao = 7           --apos a atualizaco do irisys incluir o usuario deve alterar este campo para uma variabel  

FROM dbo.tb_pgto_periodo_rota pr  
  
JOIN #LctosAtuais la  
       ON la.plm_cd_lancamentos = pr.ppr_lcto_cd_lancamento 
       and la.plm_cd_rota = pr.ppr_cd_rota
WHERE pr.ppr_cd_periodo = @CodPeriodoPagamento  
  AND pr.ppr_in_excluido = 0    
  */
  

---------------------------------------------------------------------------  
/*  
regra para zerar totas. precisa ser parametrizavel.  
--*/  
--if @clienteid in (37,66)  
--begin  
  
--    update a  
--    set   
--         ppr_vl_base         = 0   
--        ,ppr_vl_paradas      = 0   
--        ,ppr_vl_dom_fer      = 0   
--        ,ppr_vl_risco        = 0   
--        ,ppr_vl_ajudante     = 0   
--        ,ppr_vl_lancamentos  = 0    
--        ,ppr_vl_bonus        = 0   
--        ,ppr_vl_recarga      = 0   
--        ,ppr_vl_aluguel      = 0   
--        ,ppr_vl_pedagio      = 0   
--        ,ppr_vl_desconto     = 0   
--        ,ppr_vl_bonus_ds     = 0   
--        ,ppr_vl_adicional_km = 0   
   
--    from tb_pgto_periodo_rota as a  
--    inner join (  
  
--        select    
--             b.tlm_cd_rota  
--            ,a.*   
  
--        from tb_pgto_rotas_lanc_manuais as a  
  
--        join vw_lancamentos_manuais_aprovados as b  
--        on a.plm_cd_rota = b.tlm_cd_rota  
  
--        join tb_pgto_periodo_rota as c  
--        on c.ppr_cd_rota  = b.tlm_cd_rota  
--        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
--        where 1=1  
--        and plm_nm_tipo = 'PF - Endereço não visitado'  
--        and ppr_cd_periodo = @CodPeriodoPagamento  
  
--    ) as b  
--    on a.ppr_cd_rota = b.plm_cd_rota  
  
--    and a.ppr_cd_periodo = @CodPeriodoPagamento  
--end  
  

declare @DescontoNotVisited int = (
                select  prm_ds_valor
                from   tb_parametros as a
                where   prm_nm_parametro = 'Desconto Not Visited'
                        and prm_cod_cliente = @clienteid
    )


set @DescontoNotVisited = isnull(@DescontoNotVisited,0)



  
if @clienteid in (63,68,66)  
begin  
    --limita o desconto de lancamento manual das rotas   
    update a  
    set   
         ppr_vl_end_nvisitado        =  
         
             case   
                when @DescontoNotVisited = 2 then isnull(ppr_vl_base,0) * -1 --desconto_vl_base
                when @DescontoNotVisited = 1 then (isnull(ppr_vl_base,0) + isnull(ppr_vl_dom_fer,0) + isnull(ppr_vl_paradas,0) + ISNULL(ppr_vl_bonus_ds, 0) 
				                                    + ISNULL(ppr_vl_adicional_KM, 0) + isnull(ppr_vl_bonus,0) + isnull(ppr_vl_ajudante,0) + isnull(ppr_vl_risco,0)
				                                    + isnull(ppr_vl_pedagio,0) + isnull(ppr_vl_aluguel,0) + isnull(ppr_vl_recarga,0) + isnull(ppr_vl_pacotes,0)) * -1 --desconto_vl_total
                when @DescontoNotVisited = 0 then isnull(tlm_vl_valor_descontos,0) * -1 --desconto_vl_original
             end 
         
    ,   ppr_lcto_cd_lancamento = plm_cd_lancamentos
    ,   ppr_lcto_observacao    = tlm_ds_observacao

    
    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select   distinct 
             b.tlm_cd_rota  as plm_cd_rota
            ,c.ppr_cd_periodo
            ,c.ppr_cd_motorista_nfs
            ,a.plm_cd_lancamentos
            ,pf.tlm_ds_observacao
            ,b.tlm_vl_valor_descontos
        from tb_pgto_rotas_lanc_manuais as a  
  
        join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
        
        join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        join tb_pag_espelhos as pag  
        on pag.mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs  
        and  pag.mtn_cod_cliente = b.tlm_cd_cliente

        left join #LancamentosAgregadosPF as pf
        on a.plm_cd_espelhos = pf.ppr_cd_motorista_nfs
        and a.plm_cd_rota = pf.tlm_cd_rota
  
        where 1=1  
        and cast(tlm_dh_referencia as date)  between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - Endereço não visitado'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)
        and ppr_in_excluido = 0
        --and @clienteid not in (63,68,66)
        --and ppr_cd_rota  = '333743005'  
  
    ) as b  
     on  a.ppr_cd_periodo = b.ppr_cd_periodo  
    and a.ppr_cd_rota = b.plm_cd_rota  
    and a.ppr_cd_motorista_nfs = b.ppr_cd_motorista_nfs
    and ppr_in_excluido = 0
  
    where  a.ppr_cd_periodo = @CodPeriodoPagamento ;




  --pacote perdido
    update a  
    set   
         ppr_vl_pct_perdido         =  tlm_vl_valor_descontos  * -1
    ,    ppr_lcto_cd_lancamento     =  plm_cd_lancamentos
    ,    ppr_lcto_observacao        =  tlm_ds_observacao
    
         
    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select    
             b.tlm_cd_rota   as plm_cd_rota
            ,c.ppr_cd_periodo  
            ,c.ppr_cd_motorista_nfs
            ,a.plm_cd_lancamentos
            ,pf.tlm_ds_observacao
            ,sum(tlm_vl_valor_descontos) as tlm_vl_valor_descontos  

        from tb_pgto_rotas_lanc_manuais as a  
  
        join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
  
        join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        join tb_pag_espelhos as pag  
        on mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs  
        and  mtn_cod_cliente = tlm_cd_cliente

        left join #LancamentosAgregadosPF as pf
        on a.plm_cd_espelhos = pf.ppr_cd_motorista_nfs
        and a.plm_cd_rota = pf.tlm_cd_rota
  
        where 1=1  
         and cast(tlm_dh_referencia as date)  between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - Pacote Perdido'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)
        and ppr_in_excluido = 0
        --and ppr_cd_rota  = '308598011'  

        group by  b.tlm_cd_rota   ,c.ppr_cd_periodo, c.ppr_cd_motorista_nfs , plm_cd_lancamentos, pf.tlm_ds_observacao
  
    ) as b  
     on  a.ppr_cd_periodo = b.ppr_cd_periodo  
    and a.ppr_cd_rota = b.plm_cd_rota 
    and a.ppr_cd_motorista_nfs = b.ppr_cd_motorista_nfs
    and ppr_in_excluido = 0;
 


 --pnr
    update a  
    set   
         ppr_vl_pnr                 =  tlm_vl_valor_descontos  * -1
    ,    ppr_lcto_cd_lancamento     =  plm_cd_lancamentos     
    ,    ppr_lcto_observacao        =  tlm_ds_observacao


    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select    
             b.tlm_cd_rota   as plm_cd_rota
            ,c.ppr_cd_periodo 
            ,c.ppr_cd_motorista_nfs
            ,a.plm_cd_lancamentos
            ,pf.tlm_ds_observacao
            ,sum(tlm_vl_valor_descontos) as tlm_vl_valor_descontos  
  
        from tb_pgto_rotas_lanc_manuais as a  
  
        left join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
  
        left join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        left join tb_pag_espelhos as pag  
        on mtn_cd_motorista_nfs = c.ppr_cd_motorista_nfs  
        and  mtn_cod_cliente = tlm_cd_cliente

        left join #LancamentosAgregadosPF as pf
        on a.plm_cd_espelhos = pf.ppr_cd_motorista_nfs
        and a.plm_cd_rota = pf.tlm_cd_rota
  
        where 1=1  
         and cast(tlm_dh_referencia as date)   between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - PNR'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)  
        and ppr_in_excluido = 0
    group by  b.tlm_cd_rota  
            ,c.ppr_cd_periodo  
            ,c.ppr_cd_motorista_nfs
            ,plm_cd_lancamentos
            ,pf.tlm_ds_observacao



    ) as b  
     on  a.ppr_cd_periodo = b.ppr_cd_periodo  
    and a.ppr_cd_rota = b.plm_cd_rota 
    and a.ppr_cd_motorista_nfs = b.ppr_cd_motorista_nfs
    and ppr_in_excluido = 0;






  
end  
  
  


  
---------------------------------------------------------------------------  


  
  /*  
  consolidado  
  */  

  


update tb_pgto_periodo_rota    
set     

 ppr_vl_lancamentos =    
        ( 
        --isnull(ppr_vl_risco  ,0)    
        --isnull(ppr_vl_ajudante ,0)    
        --+isnull(ppr_vl_bonus  ,0)    
        +isnull(ppr_vl_recarga  ,0)    
        +isnull(ppr_vl_aluguel  ,0)    
        --+isnull(ppr_vl_pedagio  ,0)     
        +isnull(ppr_vl_desconto  ,0)     
        --+isnull(ppr_vl_bonus_ds, 0)    
        +isnull(ppr_vl_adicional_km,0)   
        +isnull(ppr_vl_pnr,0)
        +isnull(ppr_vl_pct_perdido,0)
        +isnull(ppr_vl_end_nvisitado,0)
        +isnull(ppr_vl_sem_rota,0)
        +isnull(ppr_vl_periodo_anterior,0)
        +isnull(ppr_vl_lancamentos_rotas,0)
        +isnull(ppr_vl_apoio,0)
         )              

from tb_pgto_periodo_rota 
where ppr_cd_periodo = @CodPeriodoPagamento   
and ppr_nm_pgto <> 'Avulso' 

-- and ppr_cd_pgto_espelho = 499870    


--comentado em 05/08/2026
/*
update tb_pgto_periodo_rota    
set     
    ppr_vl_total = (  
                     isnull(ppr_vl_base  ,0)    
                    +isnull(ppr_vl_paradas  ,0)    
                    +isnull(ppr_vl_dom_fer  ,0)
                    +isnull(ppr_vl_lancamentos ,0)
                    )    
 
where ppr_cd_periodo = @CodPeriodoPagamento    
-- and ppr_cd_pgto_espelho = 499870    
    
  
  
update a    
set     
 mtn_vl_nfs = total    
from     
 tb_pag_espelhos a     
 inner join (    
  select     
   sum(ppr_vl_total) as total    
   ,ppr_cd_pgto_espelho    
  from     
   tb_pgto_periodo_rota as a    
  where     
   ppr_cd_periodo = @CodPeriodoPagamento    
            and ppr_in_excluido = 0    
   and ppr_fl_desconto = 0    
  group by ppr_cd_pgto_espelho    
 ) as b    
 on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho 

 where mtn_cd_status IN (34,228,38)
 */
GO
