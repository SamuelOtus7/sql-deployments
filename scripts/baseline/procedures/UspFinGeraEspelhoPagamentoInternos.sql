-- ============================================================
-- BASELINE: dbo.UspFinGeraEspelhoPagamentoInternos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraEspelhoPagamentoInternos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- insert into tb_fin_salarios_profissionais
-- select 
--  27896 as tsp_cd_usuario
-- ,'2024-12-01' as tsp_dt_inicio
-- ,'2100-12-01' as tsp_dt_fim
-- ,3000 as tsp_vl_salario
-- ,'Analista MIS JR' as tsp_nm_cargo
-- ,0 as tsp_in_considera_sabado
-- ,0 as tsp_in_considera_domingos_feriados
-- ,getdate() as tsp_dh_criacao
-- ,7174 as tsp_cd_usr_criacao
-- ,getdate() as tsp_dh_modificacao
-- ,7174 as tsp_cd_usr_modificacao
-- ,1 as tsp_in_ativo
-- ,0 as tsp_in_excluido
-- ,27 as tsp_cd_client


CREATE procedure [dbo].[UspFinGeraEspelhoPagamentoInternos]
(
@CodPeriodoPagamento int 
) as 


	declare
      @IdTransportadora int
    -- , @CodPeriodoPagamento int = 303
    , @data_inicial date
    , @data_final date
	, @clienteid int
	, @usuarioIrisys int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	 --, @idrota varchar(50) = null
	--, @avulso int = null
    ,@tipocontrato int = null



	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)




	set @IdTransportadora = (
							select cli_id_logistics
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)


	set @tipocontrato = (
							select pgp_cd_tipo_contratos
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)

	set @IdCliTransportadora = (

						select lst_cd_lista from tb_lista
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'Interno'
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

	declare @DataPrevistaPagamento date = (  
      
		select pgp_dt_prevista_pagamento  
		from [tb_pgto_periodo] as a (NOLOCK)  
		where pgp_cd_periodo  = @CodPeriodoPagamento
     
		)

drop table if exists #tb_fin_salarios_profissionais
select 
    @CodPeriodoPagamento as ppr_cd_periodo
    ,getdate() as ppr_dh_criacao
    ,7431 as ppr_cd_usr_criacao
    ,getdate() as ppr_dh_modificacao
    ,7431 as ppr_cd_usr_modificacao
    ,1 as ppr_in_ativo
    ,0 as ppr_in_excluido
    ,tsp_vl_salario as ppr_vl_total
    ,tsp_cd_usuario as ppr_cd_motorista
    ,289455 as ppr_cd_motorista_nfs
    ,mot_nm_motorista as ppr_nome_motorista
    ,289455 as ppr_cd_pgto_espelho
    ,'Inteira'as ppr_tipo_rota
    ,'Interno' ppr_base_principal

into #tb_fin_salarios_profissionais

from tb_fin_salarios_profissionais as a
inner join tb_motorista  as b
on tsp_cd_usuario = b.mot_cd_usuario

where mot_cd_cliente = @clienteid
    and tsp_dt_inicio <= @data_inicial
    and tsp_dt_fim >= @data_final 



drop table if exists #espelho
select 
        ppr_cd_motorista as mtn_cd_motorista
		--,a.*
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,7174 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,7174 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,@clienteid as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,672 as mtn_cd_base
		--,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
		,ppr_base_principal mtn_base_principal
		, 0 as mtn_cd_operacao 

    into #espelho

from #tb_fin_salarios_profissionais

group by ppr_cd_motorista,ppr_nome_motorista,ppr_cd_periodo,ppr_base_principal



MERGE tb_pag_espelhos AS target
USING (
    SELECT
            mtn_cd_motorista
        ,mtn_cd_pgto_periodo
		,mtn_cd_operacao
        ,mtn_cd_status
        ,mtn_vl_nfs
        ,mtn_ds_link_nfs
        ,mtn_dt_prazo_contestacao
        ,mtn_dh_criacao
        ,mtn_cd_usr_criacao
        ,mtn_dh_modificacao
        ,mtn_cd_usr_modificacao
        ,mtn_in_excluido
        ,mtn_cod_cliente
        ,mtn_qt_rotas
        ,mtn_cd_tipo_espelho
        ,mtn_cd_cliente_transportadora
        ,mtn_cd_base
        ,mtn_base_principal
        ,mtn_nome_motorista
		,@DataPrevistaPagamento mtn_dt_prevista_pagamento

    FROM #espelho
    where mtn_nome_motorista is not null



) AS source
ON (
    target.mtn_nome_motorista = source.mtn_nome_motorista
    AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
    AND target.mtn_in_excluido = 0
    --and target.mtn_cd_motorista = source.mtn_cd_motorista

--		AND target.mtn_cd_base = source.mtn_cd_base
    )
WHEN MATCHED THEN
    UPDATE SET
        -- mtn_cd_status = source.mtn_cd_status
        --,
        mtn_vl_nfs = source.mtn_vl_nfs
        --,mtn_ds_link_nfs = source.mtn_ds_link_nfs
        ,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
        ,mtn_dh_criacao = source.mtn_dh_criacao
        ,mtn_cd_usr_criacao = source.mtn_cd_usr_criacao
        ,mtn_dh_modificacao = source.mtn_dh_modificacao
        ,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
        ,mtn_in_excluido = source.mtn_in_excluido
        ,mtn_cod_cliente = source.mtn_cod_cliente
        ,mtn_qt_rotas = source.mtn_qt_rotas
        ,mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho
        ,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
        ,mtn_base_principal = source.mtn_base_principal
        ,mtn_nome_motorista =  source.mtn_nome_motorista
        ,mtn_cd_base = source.mtn_cd_base
		--ajuste para atualizar somente quando a data não for atualizada manualmente
		,mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end

WHEN NOT MATCHED THEN
    INSERT (
            mtn_cd_motorista
        ,mtn_cd_pgto_periodo
		,mtn_cd_operacao 
        ,mtn_cd_status
        ,mtn_vl_nfs
        ,mtn_ds_link_nfs
        ,mtn_dt_prazo_contestacao
        ,mtn_dh_criacao
        ,mtn_cd_usr_criacao
        ,mtn_dh_modificacao
        ,mtn_cd_usr_modificacao
        ,mtn_in_excluido
        ,mtn_cod_cliente
        ,mtn_qt_rotas
        ,mtn_cd_tipo_espelho
        ,mtn_cd_cliente_transportadora
        ,mtn_base_principal
        ,mtn_nome_motorista
        ,mtn_cd_base
		,mtn_dt_prevista_pagamento
    )
    VALUES (
            source.mtn_cd_motorista
        ,source.mtn_cd_pgto_periodo
		,source.mtn_cd_operacao
        ,source.mtn_cd_status
        ,source.mtn_vl_nfs
        ,source.mtn_ds_link_nfs
        ,source.mtn_dt_prazo_contestacao
        ,source.mtn_dh_criacao
        ,source.mtn_cd_usr_criacao
        ,source.mtn_dh_modificacao
        ,source.mtn_cd_usr_modificacao
        ,source.mtn_in_excluido
        ,source.mtn_cod_cliente
        ,source.mtn_qt_rotas
        ,source.mtn_cd_tipo_espelho
        ,source.mtn_cd_cliente_transportadora
        ,source.mtn_base_principal
        ,source.mtn_nome_motorista
        ,source.mtn_cd_base
		,source.mtn_dt_prevista_pagamento
    );



MERGE INTO [tb_pgto_periodo_rota] AS target
	USING (
		SELECT
			a.ppr_cd_periodo,
			a.ppr_vl_total,
			a.ppr_cd_usr_criacao,
			a.ppr_dh_modificacao,
			a.ppr_cd_usr_modificacao,
			a.ppr_in_ativo,
			a.ppr_in_excluido,
			a.ppr_cd_motorista,
			b.mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
			@data_inicial ppr_data_referencia,
			a.ppr_base_principal,
			a.ppr_tipo_rota,
			a.ppr_nome_motorista,
			b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho

		FROM #tb_fin_salarios_profissionais AS a
		INNER JOIN tb_pag_espelhos AS b
		ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
		AND a.ppr_nome_motorista = b.mtn_nome_motorista
		--and a.ppr_base_principal = b.mtn_base_principal

		--WHERE (@idrota IS NULL OR a.ppr_cd_rota = @idrota)

	) AS source
	ON target.ppr_cd_periodo = source.ppr_cd_periodo
	AND target.ppr_cd_motorista = source.ppr_cd_motorista
	AND target.ppr_in_excluido = 0
	AND target.ppr_lcto_cd_lancamento IS NULL
	AND LTRIM(RTRIM(ISNULL(target.ppr_lcto_observacao,''))) <> 'Lançamento - Aluguel'
	--and target.ppr_base_principal = source.ppr_base_principal


	WHEN MATCHED THEN
		UPDATE SET
			
			target.ppr_vl_total = source.ppr_vl_total,
			target.ppr_cd_usr_criacao = source.ppr_cd_usr_criacao,
			target.ppr_dh_modificacao = source.ppr_dh_modificacao,
			target.ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao,
			target.ppr_in_ativo = source.ppr_in_ativo,
			target.ppr_in_excluido = source.ppr_in_excluido,
			target.ppr_cd_motorista = source.ppr_cd_motorista,
			target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
			target.ppr_data_referencia = source.ppr_data_referencia,
			target.ppr_base_principal = source.ppr_base_principal,
			target.ppr_tipo_rota = source.ppr_tipo_rota,
			target.ppr_nome_motorista = source.ppr_nome_motorista,
			target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho
			
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (            
            ppr_cd_periodo,
            ppr_vl_total,
            ppr_cd_usr_criacao,
            ppr_dh_modificacao,
            ppr_cd_usr_modificacao,
            ppr_in_ativo,
            ppr_in_excluido,
            ppr_cd_motorista,
            ppr_cd_motorista_nfs,
            ppr_data_referencia,
            ppr_base_principal,
            ppr_tipo_rota,
            ppr_nome_motorista,
            ppr_cd_pgto_espelho
		)
		VALUES (
			source.ppr_cd_periodo,
			source.ppr_vl_total,
			source.ppr_cd_usr_criacao,
			source.ppr_dh_modificacao,
			source.ppr_cd_usr_modificacao,
			source.ppr_in_ativo,
			source.ppr_in_excluido,
			source.ppr_cd_motorista,
			source.ppr_cd_motorista_nfs,
			source.ppr_data_referencia,
			source.ppr_base_principal,
			source.ppr_tipo_rota,
			source.ppr_nome_motorista,
			source.ppr_cd_pgto_espelho
		);


-- select top 10 * from tb_pag_espelhos where mtn_cd_motorista_nfs = 290798
-- select top 10 * from tb_pgto_periodo_rota where ppr_cd_motorista_nfs = 290798


-- select * from #espelho
-- where ppr_cd_periodo = 303


-- select * from tb_bases 
-- where bss_cd_base = 672

GO
