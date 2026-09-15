-- ============================================================
-- BASELINE: dbo.USP_pgto_fcargo_importar_periodo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[USP_pgto_fcargo_importar_periodo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[USP_pgto_fcargo_importar_periodo]
    @CodPeriodoPagamento INT
AS
BEGIN
    set dateformat dmy 

    --1- criar o periodo de pagamento no pagamentos
    --2- preencher a tabela tb_pgto_espelh_temp com a query import fcargo
    --3- execute esta procedure
    --4- executar  a consulta para validar se esta faltando algum coleborador select * from fn_batimento_importacao_fcargo_cpf(688)  where AbsDelta > 0 

    --select SUM(mtn_vl_nfs)  from tb_pag_espelhos where mtn_cd_pgto_periodo = 2311

    --select *  from tb_pgto_espelh_temp


    --select *  from tb_fin_prefatura where idtransportadora  = 1731064496

    --antes de inserir tem que deletar
     --delete from tb_pgto_periodo_rota where ppr_cd_periodo = 1242
     --delete from tb_pag_espelhos where mtn_cd_pgto_periodo = 1046
    -- --delete from tb_pag_espelhos where mtn_cd_motorista_nfs
    --in (618745
    --,618746
    --,618747
    --,618748
    --,618749
    --,618750
    --,618751
    --,618752
    --,618753
    --,618754
    --)

    declare
          @IdTransportadora int
        , @data_inicial date
        , @data_final date
        , @clienteid int
        , @usuarioIrisys int
        , @Motorista varchar(250)
        , @IdCliTransportadora int
        , @idrota varchar(50) = null
        --, @avulso int = null
        , @tipocontrato int = null


    --select *  from tb_motorista where mot_cpf = '39239644807'

    --select *  from tb_motorista where mot_cd_matricula = 18026

    -- select * from fn_batimento_importacao_fcargo_cpf(2422)  where AbsDelta > 0
    -- select sum(ppr_vl_total), COUNT(*) from tb_pgto_periodo_rota where ppr_cd_periodo = 421
    -- select sum(cast(ppr_vl_total as decimal(10,2))),count(*) from #tb_fin_salarios_profissionais where ppr_cd_periodo = 421
    -- select sum(mtn_vl_nfs),COUNT(*)  from tb_pag_espelhos where mtn_cd_pgto_periodo = 421
    -- select sum(mtn_vl_nfs)  from #espelho where mtn_cd_pgto_periodo = 376 and   mtn_nome_motorista is not null
    -- select * from tb_pgto_periodo_rota where ppr_cd_periodo = 376 and ppr_cd_rota is null
     --delete from tb_pgto_periodo_rota where ppr_cd_periodo = 394
     --delete from tb_pag_espelhos where mtn_cd_pgto_periodo = 403
     --update tb_pag_espelhos set mtn_cd_status = 32 where mtn_cd_pgto_periodo = 803 and mtn_ds_linkespelho is not  null

      --select mtn_ds_linkespelho, * from tb_pag_espelhos where mtn_cd_pgto_periodo = 803 and mtn_ds_linkespelho is   null
     --select * from tb_pag_espelhos where mtn_cd_pgto_periodo = 440 and mtn_ds_linkespelho is not null


     insert into tb_remove_periodo_fligth select   @CodPeriodoPagamento

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
                            where pgp_cd_periodo  = 977
                            )

    drop table if exists #tb_fin_salarios_profissionais
    select 
         @CodPeriodoPagamento as ppr_cd_periodo
        ,cast(Periodo as varchar(103))  as DataReferencia
        ,rota       as ppr_cd_rota
        ,placa      as ppr_ds_placa
        ,veiculo    as ppr_ds_tipo_veiculo
        ,pacotes  as ppr_qt_pacotes
        ,paradas  as ppr_qt_paradas
        ,getdate() as ppr_dh_criacao
        ,7431 as ppr_cd_usr_criacao
        ,getdate() as ppr_dh_modificacao
        ,7431 as ppr_cd_usr_modificacao
        ,1 as ppr_in_ativo
        ,0 as ppr_in_excluido
        ,ValorTotal as ppr_vl_total

        ,isnull(b.mot_cd_usuario,c.mot_cd_usuario) as ppr_cd_motorista
        ,289455 as ppr_cd_motorista_nfs
        ,isnull(b.mot_nm_motorista,c.mot_nm_motorista) as ppr_nome_motorista
        ,289455 as ppr_cd_pgto_espelho
        ,'Inteira'as ppr_tipo_rota
        ,'Interno' ppr_base_principal
        ,Observacao as ppr_lcto_observacao
        ,CPF

        into #tb_fin_salarios_profissionais

    from
    (
        select
        --,replace(replace(ValorTotal,'.',''),',','.') as ppr_vl_total
        Matricula,Profissional, ValorTotal, Observacao,Periodo,

        dbo.fc_ExtrairNumeros(CPF) as  CPF
        ,rota
                ,placa,veiculo,svc,pacotes,insuscesso,paradas

        --select distinct cpf,ltrim(replace(replace(replace(replace(replace(trim(replace(CPF,'"','')) ,'/',''),' ',''),'.',''),'-',''),'-',''))
        from tb_pgto_espelh_temp

         --and Matricula = 0724
        --where Profissional  = 'Alex Machado Nepomuceno'
        --,'49455356805')


        --where Profissional = 'Marco Antonio Gomes Da Silva'
    ) as a
    left join 
    (
        select 
             mot_nm_motorista
            ,max(mot_cd_usuario)  as mot_cd_usuario
            -- ,mot_cd_matricula
            ,cast(replace(replace(replace(replace(mot_cpf,'.',''),'-',''),' ',''),'/','') as bigint) mot_cpf
        from tb_motorista as motoristas
            left join tb_usuario as users 
            on motoristas.mot_cd_usuario = users.usr_cd_usuario

        where users.usr_in_motorista = 1 
                and users.usr_in_ativo = 1 
                and mot_cd_status = 1
                and users.cli_cd_codigo_cliente = 27
            --  and mot_cpf in ('35158675899','06298725466')
                 --and mot_cd_matricula = 4710
        group by mot_nm_motorista
        --  ,mot_cd_matricula
        ,cast(replace(replace(replace(replace(mot_cpf,'.',''),'-',''),' ',''),'/','') as bigint)
    )as b
    on  cast(replace(replace(replace(CPF ,'/',''),' ',''),'.','') as bigint) = b.mot_cpf

    left join (

        select 
             mot_nm_motorista
            ,max(mot_cd_usuario) as mot_cd_usuario
            ,cast(replace(replace(replace(replace(mot_cpf,'.',''),'-',''),' ',''),'/','') as bigint) mot_cpf
            -- ,mot_cd_matricula
        from tb_motorista as motoristas
        left join tb_usuario as users 
        on motoristas.mot_cd_usuario = users.usr_cd_usuario

        where isnull(users.usr_in_motorista,0) = 0 
            and users.usr_in_ativo = 1 
            and mot_cd_status = 1
            and users.cli_cd_codigo_cliente = 27
             --and mot_cpf in ('35158675899','06298725466')
             --and mot_cd_matricula = 4710
        group by mot_nm_motorista
        -- ,mot_cd_matricula
        ,cast(replace(replace(replace(replace(mot_cpf,'.',''),'-',''),' ',''),'/','') as bigint)

    ) as c
    on
    cast(replace(replace(replace(CPF ,'/',''),' ',''),'.','') as bigint) = c.mot_cpf
    -- Matricula = c.mot_cd_matricula


        update  #tb_fin_salarios_profissionais
        set ppr_qt_paradas = 1
        where   ppr_qt_paradas like '%#DIV/0!%'


        update  #tb_fin_salarios_profissionais
        set ppr_qt_paradas = 1
        where   ppr_qt_paradas like '%.%'


    --select * from #tb_fin_salarios_profissionais
    --where ppr_nome_motorista <> 'Marco Antonio Gomes Da Silva'

    --where CPF = '9538711424'



    --select  * from tb_pgto_espelh_temp where CPF = '9538711424'
    -- select * from #tb_fin_salarios_profissionais where ppr_nome_motorista = 'Rafael Rodrigues Do Nascimento'
    -- select * from #tb_fin_salarios_profissionais

    --select * from #espelho
    --select * from tb_pgto_espelh_temp where matricula  = 4710

    drop table if exists #espelho
    select 
            ppr_cd_motorista as mtn_cd_motorista
            --,a.*
            ,ppr_nome_motorista as mtn_nome_motorista
            ,ppr_cd_periodo as mtn_cd_pgto_periodo
            ,228 mtn_cd_status
            ,SUM(isnull(cast(ppr_vl_total as decimal(10,2)),0)) as mtn_vl_nfs
            ,null mtn_ds_link_nfs
            ,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
            ,getdate() mtn_dh_criacao
            ,7431 as mtn_cd_usr_criacao
            ,getdate() mtn_dh_modificacao
            ,7431 as mtn_cd_usr_modificacao
            ,0 as mtn_in_excluido
            ,@clienteid as mtn_cod_cliente
            ,count(*) as mtn_qt_rotas
            ,94  as mtn_cd_tipo_espelho
            ,@IdCliTransportadora as mtn_cd_cliente_transportadora
            ,672 as mtn_cd_base
            --,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
            ,ppr_base_principal mtn_base_principal

        into #espelho

    from #tb_fin_salarios_profissionais
    --where ppr_nome_motorista = 'Marco Antonio Gomes Da Silva'
    group by ppr_cd_motorista,ppr_nome_motorista,ppr_cd_periodo,ppr_base_principal
    -- where mtn_nome_motorista = 'Marco Antonio Gomes Da Silva'
    --select * from tb_pag_espelhos where mtn_cd_pgto_periodo =394  and  mtn_nome_motorista = 'Marco Antonio Gomes Da Silva'


    MERGE tb_pag_espelhos AS target
    USING (
        SELECT
             a.mtn_cd_motorista
            ,a.mtn_cd_pgto_periodo
            ,a.mtn_cd_status
            ,a.mtn_vl_nfs
            ,a.mtn_ds_link_nfs
            ,a.mtn_dt_prazo_contestacao
            ,a.mtn_dh_criacao
            ,a.mtn_cd_usr_criacao
            ,a.mtn_dh_modificacao
            ,a.mtn_cd_usr_modificacao
            ,a.mtn_in_excluido
            ,a.mtn_cod_cliente
            ,a.mtn_qt_rotas
            ,a.mtn_cd_tipo_espelho
            ,a.mtn_cd_cliente_transportadora
            ,a.mtn_cd_base
            ,a.mtn_base_principal
            ,a.mtn_nome_motorista
            ,1203 mtn_cd_operacao

        FROM #espelho as a
        --left join tb_pag_espelhos as b
        --on a.mtn_cd_motorista = b.mtn_cd_motorista
        --and b.mtn_cd_pgto_periodo = 2219

        where a.mtn_nome_motorista is not null
        --and b.mtn_cd_motorista is null

    ) AS source
    ON (
        target.mtn_cd_motorista = source.mtn_cd_motorista
        AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
        AND target.mtn_in_excluido = 0
        --and target.mtn_cd_motorista = source.mtn_cd_motorista

    --    AND target.mtn_cd_base = source.mtn_cd_base
        )


    WHEN MATCHED THEN
        UPDATE SET
            -- mtn_cd_status = source.mtn_cd_status
            --,
            mtn_vl_nfs = source.mtn_vl_nfs
            --,mtn_ds_link_nfs = source.mtn_ds_link_nfs
            ,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
           -- ,mtn_dh_criacao = source.mtn_dh_criacao
          --  ,mtn_cd_usr_criacao = source.mtn_cd_usr_criacao
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

    WHEN NOT MATCHED THEN
        INSERT (
                mtn_cd_motorista
            ,mtn_cd_pgto_periodo
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
            ,mtn_cd_operacao
        )
        VALUES (
                source.mtn_cd_motorista
            ,source.mtn_cd_pgto_periodo
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
            ,source.mtn_cd_operacao
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
ISNULL(TRY_CONVERT(DATE, a.DataReferencia, 101), ISNULL((SELECT MIN(TRY_CONVERT(DATE, CAST(Periodo AS VARCHAR(103)), 101)) FROM tb_pgto_espelh_temp), '2025-10-02')) AS ppr_data_referencia,

                a.ppr_base_principal,
                a.ppr_tipo_rota,
                a.ppr_nome_motorista,
                b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho,
                ppr_lcto_observacao,
                ppr_cd_rota,
                ppr_ds_placa,
                ppr_ds_tipo_veiculo,
                ppr_qt_pacotes,
                ppr_qt_paradas

            FROM #tb_fin_salarios_profissionais AS a
            INNER JOIN tb_pag_espelhos AS b
            ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
            AND a.ppr_nome_motorista = b.mtn_nome_motorista
            --and a.ppr_base_principal = b.mtn_base_principal

            --where a.ppr_nome_motorista = 'Alex Machado Nepomuceno'

            --WHERE (@idrota IS NULL OR a.ppr_cd_rota = @idrota)

        ) AS source
        ON target.ppr_cd_periodo = source.ppr_cd_periodo
        AND target.ppr_cd_rota = source.ppr_cd_rota
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
                target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
                target.ppr_lcto_observacao = source.ppr_lcto_observacao,
                target.ppr_cd_rota  =  source.ppr_cd_rota,
                target.ppr_ds_placa =  source.ppr_ds_placa,
                target.ppr_ds_tipo_veiculo =  source.ppr_ds_tipo_veiculo,
                target.ppr_qt_pacotes =  source.ppr_qt_pacotes,
                target.ppr_qt_paradas =  source.ppr_qt_paradas

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
                ppr_cd_pgto_espelho,
                ppr_lcto_observacao,
                ppr_cd_rota,
                ppr_ds_placa,
                ppr_ds_tipo_veiculo,
                ppr_qt_pacotes,
                ppr_qt_paradas
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
                source.ppr_cd_pgto_espelho,
                source.ppr_lcto_observacao,
                source.ppr_cd_rota,
                source.ppr_ds_placa,
                source.ppr_ds_tipo_veiculo,
                source.ppr_qt_pacotes,
                source.ppr_qt_paradas
            );


    --select * from     #tb_fin_salarios_profissionais
            --set dateformat dmy
            --select distinct isnull(TRY_CONVERT(DATE,DataReferencia,101),'2025-10-02') from #tb_fin_salarios_profissionais

    -- select top 10 * from tb_pag_espelhos where mtn_cd_motorista_nfs = 290798
    -- select top 10 * from tb_pgto_periodo_rota where ppr_cd_motorista_nfs = 290798

    --select *  
    --from #tb_fin_salarios_profissionais
    --where ppr_cd_rota = '218926002'

    -- select * from #espelho
    -- where ppr_cd_periodo = 303


    -- select * from tb_bases 
    -- where bss_cd_base = 672

    --select *
    --  --target.ppr_cd_periodo ,
    --  --target.ppr_cd_motorista, 
    --  --count(*)
    --from 
    --[tb_pgto_periodo_rota] AS target
    --  join (
    --    SELECT
    --      a.ppr_cd_periodo,
    --      a.ppr_vl_total,
    --      a.ppr_cd_usr_criacao,
    --      a.ppr_dh_modificacao,
    --      a.ppr_cd_usr_modificacao,
    --      a.ppr_in_ativo,
    --      a.ppr_in_excluido,
    --      a.ppr_cd_motorista,
    --      b.mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
    --      a.DataReferencia as ppr_data_referencia,
    --      a.ppr_base_principal,
    --      a.ppr_tipo_rota,
    --      a.ppr_nome_motorista,
    --      b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho,
    --      ppr_lcto_observacao,
    --            ppr_cd_rota,
    --            ppr_ds_placa,
    --            ppr_ds_tipo_veiculo,
    --            ppr_qt_pacotes,
    --            ppr_qt_paradas


    --    FROM #tb_fin_salarios_profissionais AS a
    --    INNER JOIN tb_pag_espelhos AS b
    --    ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
    --    AND a.ppr_nome_motorista = b.mtn_nome_motorista
    --    --and a.ppr_base_principal = b.mtn_base_principal

    --    where ppr_cd_motorista = 19743
    --    --WHERE (@idrota IS NULL OR a.ppr_cd_rota = @idrota)

    --  ) AS source
    --  ON target.ppr_cd_periodo = source.ppr_cd_periodo
    --  AND target.ppr_cd_rota = source.ppr_cd_rota
    --  AND target.ppr_in_excluido = 0
    --  AND target.ppr_lcto_cd_lancamento IS NULL
    --  AND LTRIM(RTRIM(ISNULL(target.ppr_lcto_observacao,''))) <> 'Lançamento - Aluguel'
    --  --and target.ppr_base_principal = source.ppr_base_principal
    --  order by 3

    --  group by   target.ppr_cd_periodo ,
    --  target.ppr_cd_motorista
    --  having count(*) > 1


    --select * from #tb_fin_salarios_profissionais
    --where ppr_cd_rota = ''


    --select
    --  * 
    --from tb_pgto_periodo
    --where pgp_cd_periodo = 536 

END
 
GO
