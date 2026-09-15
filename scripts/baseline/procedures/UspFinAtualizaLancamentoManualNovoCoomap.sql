-- ============================================================
-- BASELINE: dbo.UspFinAtualizaLancamentoManualNovoCoomap
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaLancamentoManualNovoCoomap]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspFinAtualizaLancamentoManualNovoCoomap]   (    
    @CodPeriodoPagamento VARCHAR(50),    
    @idrota VARCHAR(50) = NULL    
    ) AS    
  
 declare    
   @IdTransportadora int    
 --, @CodPeriodoPagamento int = 2546
 --, @idrota varchar(50) = null    
 , @data_inicial date    
 , @data_final date    
 , @clienteid int    
 , @usuarioIrisys int    
 , @Motorista varchar(250)    
 , @IdCliTransportadora int    
 , @tipocontrato int = null    
      

      
      
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
  
  declare @Operacao int = (select   
                                lst_cd_lista   
                            from   
                                tb_lista with(nolock)  
                            where   
                                lst_nm_lista = 'Operações Marketplace'   
                                and lst_ds_valor = 'LM'   
                                and lst_cd_cliente = @clienteid    
                            )  

    declare @DataPrevistaPagamento date = (  
      
		select pgp_dt_prevista_pagamento  
		from [tb_pgto_periodo] as a (NOLOCK)  
		where pgp_cd_periodo  = @CodPeriodoPagamento
     
		)

    --Adicionado por Saulo Barros em 06/05/2026 para poder gerar espelhos para motoristas que tiveram lançamento manual 
	--mas não tem espelho gerado. Este processo só é feito para clientes que estão parametrizados para que seja realizado
	declare @CriarEspelho int = (select prm_ds_valor from tb_parametros where prm_nm_parametro = 'Geração automática de espelho' and prm_cod_cliente = @clienteid)
	if @CriarEspelho = 1
	begin
			
		--Retorna todos os lançamentos do período
		drop table if exists #lancamentos_criacao
		select
			*
			into #lancamentos_criacao
		from
			(
				select  
					tlm_cd_cliente  
					,tlm_cd_rota  
					,case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end tlm_ds_observacao  
					,tlm_cd_lancamento_manual  
					,trim(cast(tlm_cd_rota as varchar(50))) as IdRota  
					,tlm_dh_referencia as Data  
					,tlm_cd_motorista as ppr_nome_motorista  
					,usr_cd_usuario  
					,cast(tlm_dh_referencia as date) ppr_data_referencia  
					,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end ppr_vl_lancamentos  
					,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) + case when a.plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end ppr_vl_total  
					,alm_ds_status   
					,a.plm_nm_tipo  
					,a.tlm_cd_service_center ppr_base_principal  
					,tlm_cd_tipo
				from
					--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
					--vw_lancamentos_manuais a  
					vw_lancamentos_manuais_aprovados a  
					join tb_usuario as b (NOLOCK)  on a.tlm_cd_motorista = b.usr_nm_usuario  
													and cli_cd_codigo_cliente = tlm_cd_cliente 
													and b.usr_in_ativo = 1
				where   
					tlm_in_ativo = 1  
					and plm_in_calculo_desconto = 0  
					and (@idrota is null or tlm_cd_rota = @idrota)  
					and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
					and tlm_cd_cliente = @clienteid  
					and a.Operacao = 'LM'  
					and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
					and 
					(
						(tlm_cd_rota is null or tlm_cd_rota = 'null' or tlm_cd_rota = '')
						or
						(
							tlm_cd_rota is not null 
							and tlm_cd_rota <> 'null' 
							and tlm_cd_rota <> '' 
							and not exists (select 1 from tb_pgto_periodo_rota p where p.ppr_cd_periodo = @CodPeriodoPagamento and p.ppr_cd_rota is not null and p.ppr_lcto_cd_lancamento is null and tlm_cd_rota = ppr_cd_rota)
						)
					)
						
   
				union  
  
				select  
					tlm_cd_cliente  
					,tlm_cd_rota  
					,case when isnull(rtrim(ltrim(tlm_ds_observacao)),'') = '' then plm_nm_tipo else tlm_ds_observacao end tlm_ds_observacao
					,tlm_cd_lancamento_manual  
					,trim(cast(tlm_cd_rota as varchar(50))) as IdRota  
					,tlm_dh_referencia as Data  
					,tlm_ds_motorista_apoio ppr_nome_motorista  
					,usr_cd_usuario  
					,cast(tlm_dh_referencia as date) ppr_data_referencia  
					,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end AS ppr_vl_lancamentos  
					,case when alm_ds_status = 'Aprovado' then tlm_vl_valor_apoio else 0 end ppr_vl_total  
					,alm_ds_status   
					,a.plm_nm_tipo  
					,a.tlm_cd_service_center ppr_base_principal
					,tlm_cd_tipo
				from
					--Alterado por Saulo Barros em 21/07 para buscar da view de aprovados
					--vw_lancamentos_manuais a  
					vw_lancamentos_manuais_aprovados a
					join tb_usuario as b (NOLOCK) on tlm_ds_motorista_apoio = b.usr_nm_usuario  
														and cli_cd_codigo_cliente = tlm_cd_cliente  
														and b.usr_in_ativo = 1
					
  
				where   
						tlm_in_ativo = 1  
						and plm_in_calculo_desconto = 0  
						and (@idrota is null or tlm_cd_rota = @idrota)  
						and cast(tlm_dh_referencia as date) BETWEEN @data_inicial and @data_final  
						and tlm_cd_cliente = @clienteid  
						and a.plm_nm_tipo = 'Apoio'  
						and a.Operacao = 'LM'  
						and a.tlm_cd_cliente_transportadora = @IdCliTransportadora
			) t


			if @clienteid not in (11,1,56)
			begin
				update
					r
				set
					r.ppr_base_principal = r2.ppr_base_principal
				from
					#lancamentos_criacao r
					join (
						select
							ppr_nome_motorista
							,ppr_base_principal
							,row_number() over(partition by ppr_nome_motorista order by count(*) desc, ppr_base_principal desc) as ordem
						from
							#lancamentos_criacao
						group by
							ppr_nome_motorista
							,ppr_base_principal
					) r2 on isnull(r.ppr_nome_motorista, N'') = isnull(r2.ppr_nome_motorista, N'')
						and r2.ordem = 1
			end

			-- cria espelho caso ainda não exista
			insert into tb_pag_espelhos (mtn_cd_motorista, mtn_nome_motorista, mtn_cd_pgto_periodo, mtn_cd_status, mtn_vl_nfs, mtn_ds_link_nfs, mtn_dt_prazo_contestacao, mtn_dh_criacao, mtn_cd_usr_criacao, mtn_dh_modificacao, mtn_cd_usr_modificacao, mtn_in_excluido, mtn_cod_cliente, mtn_qt_rotas, mtn_cd_tipo_espelho, mtn_cd_cliente_transportadora, mtn_cd_base, mtn_base_principal, mtn_vl_desconto, mtn_cd_operacao, mtn_dt_prevista_pagamento)
			select 
				usr_cd_usuario mtn_cd_motorista
				,ppr_nome_motorista as mtn_nome_motorista
				,@CodPeriodoPagamento as mtn_cd_pgto_periodo
				,228 mtn_cd_status
				,0 as mtn_vl_nfs
				,null mtn_ds_link_nfs
				,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
				,getdate() mtn_dh_criacao
				,8851 as mtn_cd_usr_criacao
				,getdate() mtn_dh_modificacao
				,8851 as mtn_cd_usr_modificacao
				,0 as mtn_in_excluido
				,@clienteid as mtn_cod_cliente
				,count(*) as mtn_qt_rotas
				,94  as mtn_cd_tipo_espelho
				,@IdCliTransportadora as mtn_cd_cliente_transportadora
				,bss_cd_base as mtn_cd_base
				,ppr_base_principal mtn_base_principal
				,SUM(isnull(ppr_vl_total,0)) mtn_vl_desconto
				,@Operacao mtn_cd_operacao
                ,@DataPrevistaPagamento mtn_dt_prevista_pagamento
			from 
				#lancamentos_criacao as a 
				left join tb_pag_espelhos as e on (a.ppr_nome_motorista = e.mtn_nome_motorista or a.usr_cd_usuario = e.mtn_cd_motorista)
												and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
												and e.mtn_cd_operacao = @Operacao
												and e.mtn_in_excluido = 0
												and mtn_cd_cliente_transportadora = @IdCliTransportadora
												--Criar parametro para dizer se o espelho do motorista varia para cada svc
												and (
													(@clienteid in (11,1,56) and a.ppr_base_principal = e.mtn_base_principal)
													or
													@clienteid not in (11,1,56)
												)

				left join tb_bases as c on a.ppr_base_principal = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
			where
				e.mtn_cd_motorista_nfs is null
			group by
				usr_cd_usuario
				,ppr_nome_motorista
				,bss_cd_base
				,ppr_base_principal

	end
	--Fim condição para criar espelho



    /* ======================  
       #Lancamentos (temp)  
       ====================== */  
    DROP TABLE IF EXISTS #Lancamentos;  
    SELECT  
          @CodPeriodoPagamento                       AS Periodo  
        , CAST(a.tlm_dh_referencia AS date)          AS Data 
        , a.tlm_cd_service_center
        , a.tlm_cd_lancamento_manual  
        , a.tlm_ds_observacao  
        , case when a.tlm_cd_rota = 'null' or a.tlm_cd_rota = '' then null else a.tlm_cd_rota end  as tlm_cd_rota  
        , a.plm_nm_tipo  
        , a.tlm_cd_motorista  
        , a.tlm_ds_motorista_apoio  
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
  
    /* ==========================================  
       #LancamentosAgregados (somente com rota)  
       ========================================== */  
      
    DROP TABLE IF EXISTS #LancamentosAgregados;  
    select   
    mtn_cd_motorista_nfs ppr_cd_motorista_nfs  
    ,tlm_cd_rota  
    ,tlm_ds_observacao
    ,vl_valor 
    ,0 as ppr_vl_pnr
    ,0 as ppr_vl_pct_perdido
    ,0 as ppr_vl_end_nvisitado

    into  #LancamentosAgregados  

    from   
    (  
            SELECT
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center) ServiceCenter,
                STRING_AGG(l.tlm_ds_observacao, ' || ') AS tlm_ds_observacao,
                SUM(l.tlm_vl_valor_descontos
                  + l.tlm_vl_valor_adicional
                  + l.tlm_vl_valor_rota
                  + l.tlm_vl_valor_apoio) AS vl_valor
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
                coalesce(case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else r.ServiceCenter end,tlm_cd_service_center)
     ) as l  
     left JOIN dbo.tb_pag_espelhos AS pr WITH (NOLOCK)  
            ON pr.mtn_nome_motorista    = l.tlm_cd_motorista  
           AND pr.mtn_cd_pgto_periodo   = @CodPeriodoPagamento
           and (pr.mtn_base_principal   = l.ServiceCenter or l.ServiceCenter is null)
           and pr.mtn_in_excluido = 0
           --and l.tlm_cd_rota =  '335030571'
  




    DROP TABLE IF EXISTS #LancamentosAgregadosPF;
    select   
         mtn_cd_motorista_nfs ppr_cd_motorista_nfs  
        ,tlm_cd_rota  
        ,null tlm_ds_observacao
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
                SUM(l.tlm_vl_valor_descontos
                  + l.tlm_vl_valor_adicional
                  + l.tlm_vl_valor_rota
                  + l.tlm_vl_valor_apoio) AS vl_valor
                ,sum(case when tlm_ds_observacao like '%pnr%' then l.tlm_vl_valor_descontos else null end)             as ppr_vl_pnr
                ,sum(case when tlm_ds_observacao like '%lost%' then l.tlm_vl_valor_descontos else null end)              as ppr_vl_pct_perdido
                ,sum(case when tlm_ds_observacao like '%Daily Not Visited%' then l.tlm_vl_valor_descontos else null end) as ppr_vl_end_nvisitado
                ,case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.origemsaida then r.origemsaida else r.servicecenter end  end ServiceCenter

            FROM #Lancamentos AS l
            left join tb_ml_rotas as r with(nolock)
                on l.tlm_cd_rota = r.IdRota
            left join tb_bases as bss
                on r.origemsaida = bss.bss_ds_sigla and r.IdTransportadora = bss.bss_cd_idtransportadora and bss.bss_espelho_xpt = 1
            where plm_nm_tipo LIKE '%PF%'
            --and tlm_cd_rota = '333743005'
            GROUP BY
                l.tlm_cd_rota,
                l.tlm_cd_motorista,
               case when bss.bss_espelho_xpt = 1 then r.OrigemSaida else case when r.ServiceCenter <> r.origemsaida then r.origemsaida else r.servicecenter end  end
     ) as l  
     JOIN dbo.tb_pag_espelhos AS pr WITH (NOLOCK)  
            ON pr.mtn_nome_motorista    = l.tlm_cd_motorista  
           --and (pr.mtn_base_principal   = l.ServiceCenter or l.ServiceCenter is null)
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
            select * from #LancamentosAgregados 
            union all
            select * from #LancamentosAgregadosPF
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
            ON e.mtn_nome_motorista  = l.tlm_cd_motorista  
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
            ON e.mtn_nome_motorista  = l.tlm_cd_motorista  
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
    WHERE pr.ppr_cd_periodo = @CodPeriodoPagamento  
        and pr.ppr_vl_periodo_anterior is null
        and pr.ppr_in_excluido = 0 

    --and  plm_cd_lancamentos = 3997  
  




    /* ============================================================  
       4) Insere créditos de APOIO (com rota)  
       ============================================================ */  
    INSERT INTO dbo.tb_pgto_periodo_rota  
        ( ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao  
        , ppr_vl_apoio, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho  
        , ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao  
        , ppr_in_ativo, ppr_in_excluido  
        , ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_base_principal ,ppr_lcto_cd_lancamento
		, ppr_cd_tipo_pgto,ppr_nm_pgto,ppr_driver_id)  

    SELECT  
          l.tlm_cd_rota                             AS ppr_cd_rota  
        , l.tlm_ds_motorista_apoio                  AS ppr_nome_motorista  
        , l.Data                                    AS ppr_data_referencia  
        , l.tlm_ds_observacao                       AS ppr_lcto_observacao  
        , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_apoio  
        , l.tlm_vl_valor_apoio * -1                 AS ppr_vl_total  
        , @CodPeriodoPagamento                      AS ppr_cd_periodo  
        , e.mtn_cd_motorista_nfs                    AS ppr_cd_pgto_espelho  
        , GETDATE()                                 as ppr_dh_criacao  
        , 7                                         as ppr_cd_usr_criacao  
        , GETDATE()                                 as ppr_dh_modificacao  
        , 7                                         as ppr_cd_usr_modificacao  
        , 1                                         as ppr_in_ativo  
        , 0                                         as ppr_in_excluido  
        , e.mtn_cd_motorista                        AS ppr_cd_motorista  
        , e.mtn_cd_motorista_nfs                    AS ppr_cd_motorista_nfs  
        , e.mtn_base_principal                      AS ppr_base_principal  
        , m.plm_cd_lancamentos                      AS ppr_lcto_cd_lancamento  
		, 1363										AS ppr_cd_tipo_pgto
        , 'Manual'                                  as ppr_nm_pgto
        , e.mtn_driver_id                           as ppr_driver_id
  
    FROM #Lancamentos AS l  
    INNER JOIN dbo.tb_pag_espelhos AS e WITH (NOLOCK)  
           ON e.mtn_nome_motorista  = l.tlm_ds_motorista_apoio 
           and e.mtn_base_principal = l.tlm_cd_service_center
           AND e.mtn_cd_pgto_periodo = @CodPeriodoPagamento  
    LEFT  JOIN dbo.tb_pgto_rotas_lanc_manuais AS m WITH (NOLOCK)  
           ON m.plm_cd_rota         = l.tlm_cd_rota  
           AND m.plm_cd_espelhos     = e.mtn_cd_motorista_nfs  
    WHERE l.plm_nm_tipo = 'Apoio'  
      AND e.mtn_cd_status IN (34,228,38)
      and l.tlm_cd_rota is not null
      AND NOT EXISTS (  
            SELECT 1  
            FROM dbo.tb_pgto_periodo_rota AS pr WITH (NOLOCK)  
            WHERE pr.ppr_cd_periodo      = @CodPeriodoPagamento  
              AND pr.ppr_cd_pgto_espelho = e.mtn_cd_motorista_nfs  
              AND pr.ppr_cd_rota         = l.tlm_cd_rota  
              AND pr.ppr_data_referencia = l.Data  
              AND pr.ppr_lcto_observacao = l.tlm_ds_observacao  
              AND pr.ppr_base_principal  = l.tlm_cd_service_center  
              and pr.ppr_in_excluido = 0
      )

      --and l.tlm_cd_rota = '335030571'
      ;  
  

 --select *  from #LancamentosAgregadosPF where tlm_cd_rota = 326624026

    /* ============================================================  
       5) Insere as rotas dos periodos anteriores   
       ============================================================ */  
MERGE INTO dbo.tb_pgto_periodo_rota AS target
USING (
   
   SELECT DISTINCT
          m.plm_cd_rota                                                         AS ppr_cd_rota
        , e.mtn_nome_motorista                                                  AS ppr_nome_motorista
        , @data_inicial                                                         AS ppr_data_referencia
        , null                                                                  AS ppr_lcto_observacao
        , case when tipo = 'Manual'  then vl_valor else null end                AS ppr_vl_periodo_anterior
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
        , l.ppr_vl_pnr                                                          AS ppr_vl_pnr
        , l.ppr_vl_pct_perdido   AS ppr_vl_pct_perdido
        , l.ppr_vl_end_nvisitado AS ppr_vl_end_nvisitado
        , 'Manual'                                                              as ppr_nm_pgto
        , e.mtn_driver_id                                                       as ppr_driver_id

   FROM (

       
            select 
                 ppr_cd_motorista_nfs	
                ,tlm_cd_rota	
                --,tlm_ds_observacao	
                ,vl_valor	
                ,'Manual' AS tipo 
                ,'0.0'ppr_vl_pnr	
                ,'0.0'ppr_vl_pct_perdido	
                ,'0.0'ppr_vl_end_nvisitado
                ,DataReferencia
            from #LancamentosAgregados as a
            inner join tb_ml_rotas as r
            on idrota = tlm_cd_rota
            and excluido = 0
            and statusrota <> 'planned'

            union all
            select 
                 ppr_cd_motorista_nfs
                ,tlm_cd_rota
                --,tlm_ds_observacao
                ,vl_valor
                , 'PF'  AS tipo
                ,ppr_vl_pnr
                ,ppr_vl_pct_perdido
                ,ppr_vl_end_nvisitado
                ,DataReferencia
            from #LancamentosAgregadosPF as a 
            inner join tb_ml_rotas as r
            on idrota = tlm_cd_rota
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
        , l.tlm_cd_motorista                                    AS ppr_nome_motorista
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
            ON e.mtn_nome_motorista  = l.tlm_cd_motorista
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
                        and prm_cod_cliente = 66
    )


set @DescontoNotVisited = isnull(@DescontoNotVisited,0)



  
if @clienteid in (63,68,66)  
begin  
    --limita o desconto de lancamento manual das rotas   
    update a  
    set   
         ppr_vl_end_nvisitado        =  
         
             case   
                when @clienteid = 63 and DataReferenciaRota < @data_inicial then isnull(ppr_vl_base_periodo_origem,0) * -1 --desconto_vl_base_periodo_anterior
                when @DescontoNotVisited = 2 then isnull(ppr_vl_base,0) * -1 --desconto_vl_base
                when @DescontoNotVisited = 1 then (isnull(ppr_vl_base,0) + isnull(ppr_vl_dom_fer,0) + isnull(ppr_vl_paradas,0) + ISNULL(ppr_vl_bonus_ds, 0) 
				                                    + ISNULL(ppr_vl_adicional_KM, 0) + isnull(ppr_vl_bonus,0) + isnull(ppr_vl_ajudante,0) + isnull(ppr_vl_risco,0)
				                                    + isnull(ppr_vl_pedagio,0) + isnull(ppr_vl_aluguel,0) + isnull(ppr_vl_recarga,0) + isnull(ppr_vl_pacotes,0)) * -1 --desconto_vl_total
                when @DescontoNotVisited = 0 then isnull(tlm_vl_valor_descontos,0) * -1 --desconto_vl_original
             end 
         
    ,   ppr_lcto_cd_lancamento = plm_cd_lancamentos   
    
    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select   distinct 
             b.tlm_cd_rota  as plm_cd_rota
            ,ppr_cd_periodo
            ,ppr_cd_motorista_nfs
            ,plm_cd_lancamentos
            ,tlm_vl_valor_descontos
            ,rnv.DataReferencia as DataReferenciaRota
            ,valorPeriodoAnterior.ppr_vl_base as ppr_vl_base_periodo_origem
        from tb_pgto_rotas_lanc_manuais as a  
  
        join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
        
        join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        join tb_pag_espelhos as pag  
        on mtn_cd_motorista_nfs = ppr_cd_motorista_nfs  
        and  mtn_cod_cliente = tlm_cd_cliente

        left join tb_ml_rotas as rnv with(nolock)
        on try_convert(bigint, b.tlm_cd_rota) = rnv.IdRota
        and rnv.Excluido = 0

        outer apply (
            select top (1)
                prOrigem.ppr_vl_base
            from tb_pgto_periodo as ppOrigem with(nolock)
            join tb_pgto_periodo_rota as prOrigem with(nolock)
                on prOrigem.ppr_cd_periodo = ppOrigem.pgp_cd_periodo
               and prOrigem.ppr_cd_rota = b.tlm_cd_rota
               and prOrigem.ppr_in_excluido = 0
               and isnull(prOrigem.ppr_nm_pgto, '') <> 'Manual'
            where ppOrigem.pgp_cd_cliente = b.tlm_cd_cliente
              and rnv.DataReferencia between ppOrigem.pgp_dt_inicio and ppOrigem.pgp_dt_fim
            order by
                case when prOrigem.ppr_vl_base is not null then 0 else 1 end,
                prOrigem.ppr_cd_motorista_nfs
        ) as valorPeriodoAnterior
  
        where 1=1  
        and cast(tlm_dh_referencia as date)  between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - Endereço não visitado'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)
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
         
    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select    
             b.tlm_cd_rota   as plm_cd_rota
            ,ppr_cd_periodo  
            ,ppr_cd_motorista_nfs
            ,plm_cd_lancamentos
            ,sum(tlm_vl_valor_descontos) as tlm_vl_valor_descontos  

        from tb_pgto_rotas_lanc_manuais as a  
  
        join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
  
        join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        join tb_pag_espelhos as pag  
        on mtn_cd_motorista_nfs = ppr_cd_motorista_nfs  
        and  mtn_cod_cliente = tlm_cd_cliente
  
        where 1=1  
         and cast(tlm_dh_referencia as date)  between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - Pacote Perdido'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)
        --and ppr_cd_rota  = '308598011'  

        group by  b.tlm_cd_rota   ,ppr_cd_periodo, ppr_cd_motorista_nfs , plm_cd_lancamentos
  
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

    from tb_pgto_periodo_rota as a  
    inner join (  
  
        select    
             b.tlm_cd_rota   as plm_cd_rota
            ,ppr_cd_periodo 
            ,ppr_cd_motorista_nfs
            ,plm_cd_lancamentos
            ,sum(tlm_vl_valor_descontos) as tlm_vl_valor_descontos  
  
        from tb_pgto_rotas_lanc_manuais as a  
  
        left join vw_lancamentos_manuais_aprovados as b  
        on a.plm_cd_rota = b.tlm_cd_rota  
  
        left join tb_pgto_periodo_rota as c  
        on c.ppr_cd_rota  = b.tlm_cd_rota  
        and c.ppr_cd_motorista_nfs = a.plm_cd_espelhos  
  
        left join tb_pag_espelhos as pag  
        on mtn_cd_motorista_nfs = ppr_cd_motorista_nfs  
        and  mtn_cod_cliente = tlm_cd_cliente
  
        where 1=1  
         and cast(tlm_dh_referencia as date)   between  @data_inicial and @data_final   
        and plm_nm_tipo = 'PF - PNR'  
        and ppr_cd_periodo = @CodPeriodoPagamento  
        AND mtn_cd_status IN (34,228,38)  
    group by  b.tlm_cd_rota  
            ,ppr_cd_periodo  
            ,ppr_cd_motorista_nfs
            ,plm_cd_lancamentos


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

GO
