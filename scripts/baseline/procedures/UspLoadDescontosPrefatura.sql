-- ============================================================
-- BASELINE: dbo.UspLoadDescontosPrefatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadDescontosPrefatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspLoadDescontosPrefatura] 
(
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
AS

 

--BEGIN
----    --SET NOCOUNT ON;

--declare	@IdTransportadora int = 1024706007,
--	@Ano int = 2026,
--	@Mes tinyint = 1,
--	@Quinzena tinyint = 1

	delete tb_fin_prefatura_descontos where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
    delete tb_descontos_prefatura_erros where dpe_id_transportadora = @IdTransportadora and dpe_ano = @Ano and dpe_mes = @Mes and dpe_quinzena = @Quinzena

    declare @Cliente int = (
                        select  cli_cd_codigo_cliente
                        from    tb_clientes cli with(nolock)
						where   cli.cli_id_logistics = @IdTransportadora
								and cli.cli_cd_codigo_cliente <> 7
    )

	declare	@Operacao int = (

                        select  l.lst_cd_lista
						from    tb_clientes cli with(nolock)
					    join    tb_lista l with(nolock) on cli.cli_cd_codigo_cliente = l.lst_cd_cliente 
										and l.lst_nm_lista = 'Operações Marketplace' 
										and l.lst_ds_valor = 'LM'
						where   cli.cli_id_logistics = @IdTransportadora
								and cli.cli_cd_codigo_cliente <> 7
	)

    declare @NotVisited int = (
                        select  prm_ds_valor
                        from    tb_parametros a with(nolock)
                        where   prm_ds_categoria = 'Descontos Pre Fatura'
                                and prm_nm_parametro = 'Vehicle Daily Not Visited'
                                and prm_cod_cliente = @Cliente
    )

    declare @Pnr    int = (
                        select  prm_ds_valor
                        from    tb_parametros a with(nolock)
                        where   prm_ds_categoria = 'Descontos Pre Fatura'
                                and prm_nm_parametro = 'Pnr Packages Penalty'
                                and prm_cod_cliente = @Cliente
    )

    declare @LostPackges int = (
                        select  prm_ds_valor
                        from    tb_parametros a with(nolock)
                        where   prm_ds_categoria = 'Descontos Pre Fatura'
                                and prm_nm_parametro = 'Lost Packages Penalty'
                                and prm_cod_cliente = @Cliente
    )


    set @NotVisited = isnull(@NotVisited,0)
    set @LostPackges = isnull(@LostPackges,0)
    set @Pnr = isnull(@Pnr,0)



    -- Etapa 1: Criação da tabela temporária
    DROP TABLE IF EXISTS #prefatura_lanc;

    SELECT DISTINCT 
         IdTransportadora
        ,Ano
        ,Mes
        ,Quinzena
        ,Produto                    AS descricao
        ,Pais                       AS id_rota
        ,Transportadora             AS data_inicio
        ,Milha                      AS data_termino
        ,IDPrefatura                AS placa
        ,Periodo                    AS motorista
        ,TipoPreFatura              AS quantidade
        ,StatusPrefatura            AS preco_unitario
        ,Column8                    AS total
        ,NULL                       AS Parada
        ,NULL                       AS VLParada
    INTO #prefatura_lanc
    FROM tb_fin_prefatura_upload
	 where 
		IdTransportadora = @IdTransportadora
		and Ano = @Ano
		and Mes = @Mes
		and Quinzena = @Quinzena

  
	;

    -- Etapa 2: Limpeza de registros inválidos
    DELETE FROM #prefatura_lanc 
    WHERE TRY_CAST(id_rota AS INT) IS NULL OR id_rota = ''
    and descricao not like '%pnr packages penalty%'
    ;

    -- Etapa 3: CTE para tratamento das penalidades
    WITH CTE_DadosProntos AS (

        SELECT DISTINCT
             IdTransportadora
            ,Ano
            ,Mes
            ,Quinzena
            ,TRY_CAST(RIGHT(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + LEFT(data_termino,2) AS DATE) AS DataReferencia
            ,TRY_CAST(id_rota AS INT) AS IdRota
            ,REVERSE(LEFT(REVERSE(descricao), CHARINDEX(' ', REVERSE(descricao)) - 1)) AS IdPacote
            ,CASE 
                WHEN descricao LIKE '%pnr packages penalty%' THEN 1 
                WHEN descricao LIKE '%lost packages penalty%' THEN 2 
                ELSE 0 
             END AS IdPenalidade
            ,descricao AS Descricao
            ,TRY_CAST(quantidade AS TINYINT) AS Quantidade
            ,TRY_CAST(preco_unitario AS DECIMAL(7,2)) AS PrecoUnitario
            ,TRY_CAST(total AS DECIMAL(7,2)) AS Total
			,DATEFROMPARTS(Ano, Mes, CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END) AS DataQuinzena
            ,Motorista
        FROM #prefatura_lanc
        WHERE (descricao LIKE '%pnr packages penalty%' OR descricao LIKE '%lost packages penalty%')
        and TRY_CAST(id_rota AS INT)   <> ''

    union 

         SELECT DISTINCT
             a.IdTransportadora
            ,Ano
            ,Mes
            ,Quinzena
            ,p.DataReferencia AS DataReferencia
            ,p.IdRota AS IdRota
            ,REVERSE(LEFT(REVERSE(descricao), CHARINDEX(' ', REVERSE(descricao)) - 1)) AS IdPacote
            ,CASE 
                WHEN descricao LIKE '%pnr packages penalty%' THEN 1 
                WHEN descricao LIKE '%lost packages penalty%' THEN 2 
                ELSE 0 
             END AS IdPenalidade
            ,descricao AS Descricao
            ,TRY_CAST(quantidade AS TINYINT) AS Quantidade
            ,TRY_CAST(preco_unitario AS DECIMAL(7,2)) AS PrecoUnitario
            ,TRY_CAST(total AS DECIMAL(7,2)) AS Total
			,DATEFROMPARTS(Ano, Mes, CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END) AS DataQuinzena
            ,r.nomemotorista Motorista
        FROM #prefatura_lanc as a
        
        inner join tb_ml_pacotes as p
        on REVERSE(LEFT(REVERSE(descricao), CHARINDEX(' ', REVERSE(descricao)) - 1)) = idpacote
        and a.IdTransportadora  = p.IdTransportadora 
        
        inner join tb_ml_rotas as r
        on p.idrota  = r.idrota
        and p.IdTransportadora  = r.IdTransportadora

        WHERE 1=1  
        and id_rota  = ''
        and r.excluido = 0
        and r.StatusRota <> 'planned'
        and descricao LIKE '%pnr packages penalty%'

   

        UNION

        SELECT DISTINCT
             IdTransportadora
            ,Ano
            ,Mes
            ,Quinzena
			
            ,TRY_CONVERT(DATE, REVERSE(LEFT(REVERSE(descricao), CHARINDEX(' ', REVERSE(descricao)) - 1)), 103) AS DataReferencia
            ,TRY_CAST(id_rota AS INT)
            ,NULL
            ,3
            ,descricao
            ,NULL
            ,preco_unitario
            ,Total
			,DATEFROMPARTS(Ano, Mes, CASE WHEN Quinzena = 1 THEN 1 ELSE 16 END) AS DataQuinzena
            ,motorista

	   FROM #prefatura_lanc
        WHERE descricao LIKE '%Vehicle Daily Not Visited%'
    
    
    )
  
 --   select * from CTE_DadosProntos

     --Etapa 4: Inserção em tb_fin_prefatura_descontos
    INSERT INTO tb_fin_prefatura_descontos (
         IdTransportadora
        ,Ano
        ,Mes
        ,Quinzena
        ,DataReferencia
        ,IdRota
        ,IdPacote
        ,IdPenalidade
        ,Descricao
        ,Quantidade
        ,PrecoUnitario
        ,Total		
		,DataQuinzena
        ,Motorista
		,DataAtualizacao
        ,UsuarioDA
       
    )
     SELECT 
        dp.*
        ,getdate() DataAtualizacao
        ,r.UsuarioDA
    FROM 
        CTE_DadosProntos dp
        left join tb_ml_rotas as r with(nolock) on dp.idrota  = r.idrota
                                            and dp.IdTransportadora  = r.IdTransportadora
                                            and r.Excluido = 0
                                            and r.statusrota <> 'planned'
    WHERE NOT EXISTS (
        SELECT 1
        FROM tb_fin_prefatura_descontos t
        WHERE  t.IdTransportadora = dp.IdTransportadora
            AND t.Ano             = dp.Ano
            AND t.Mes             = dp.Mes
            AND t.Quinzena        = dp.Quinzena
            AND t.DataReferencia  = dp.DataReferencia
            AND t.IdRota          = dp.IdRota
            AND t.IdPenalidade    = dp.IdPenalidade
    )
    ;


    --insere descontos que não foi possível associar a um usuário do Irisys
    insert into tb_descontos_prefatura_erros (dpe_id_transportadora, dpe_ano, dpe_mes, dpe_quinzena, dpe_cd_rota, dpe_cd_pacote, dpe_ds_desconto, dpe_nm_motorista, dpe_ds_erro, dpe_dh_criacao)
    select 
        IdTransportadora dpe_id_transportadora
        ,Ano dpe_ano
        ,Mes dpe_mes
        ,Quinzena dpe_quinzena
        ,IdRota dpe_cd_rota
        ,IdPacote dpe_cd_pacote
        ,Descricao dpe_ds_desconto
        ,Motorista dpe_nm_motorista
        ,'Não foi possível inserir o desconto em lançamentos manuais pois não foi encontrado um usuário do Irisys correspondente.' dpe_ds_erro 
        ,getdate() dpe_dh_criacao
    from 
        tb_fin_prefatura_descontos 
    where 
        IdTransportadora = @IdTransportadora 
        and Ano = @Ano 
        and Mes = @Mes 
        and Quinzena = @Quinzena
        and UsuarioDA is null

    
    -- Etapa 5: Inserção em tb_lancamentos_manuais

    INSERT INTO tb_lancamentos_manuais (
		tlm_cd_rota,tlm_cd_service_center ,tlm_cd_motorista,tlm_cd_tipo ,tlm_cd_periodo,tlm_cd_risco_ajudante,tlm_cd_quantidade_pacotes ,tlm_cd_pontos ,tlm_ds_observacao ,tlm_cd_cliente ,tlm_in_ativo ,tlm_in_excluido  ,tlm_cd_usuario_criacao
        ,tlm_dh_criacao ,tlm_cd_usuario_modificacao ,tlm_dh_modificacao  ,tlm_cd_transportadora  ,tlm_in_marketplace  ,tlm_ds_motorista_apoio ,tlm_tipo_valor_apoio  ,tlm_vl_valor_apoio  ,tlm_cd_tipo_veiculo_nao_utilizado  ,tlm_dh_nao_utilizado  ,tlm_dh_referencia  ,tlm_cd_arquivo
        ,tlm_cd_cliente_transportadora  ,tlm_vl_valor_rota ,tlm_vl_valor_adicional ,tlm_ds_motorista_secundario ,tlm_vl_valor_descontos ,tlm_ds_matricula ,tlm_ds_placa ,tlm_cd_mot ,tlm_cd_mot_apoio,tlm_tp_credito_debito,
		tlm_cd_operacao
		)

    SELECT distinct 
         tlm_cd_rota                         = PFD.idrota
        ,tlm_cd_service_center               = COALESCE(v.vei_ds_base_espelho,CASE WHEN bss.bss_espelho_xpt = 1 THEN mlr.OrigemSaida ELSE MLR.ServiceCenter END) --regra para carregar o desconto no SVC correto
        ,tlm_cd_motorista                    = PFD.Motorista
        ,tlm_cd_tipo                         = plm_cd_tipo_lancamento_manual --codigo criado na tabela tb_tipos_lancamentos_manuais para os tipos 'PF - Endereço não visitado', 'PF - Pacote Perdido', 'PF - PNR' de acordo com a transportadora colocar o id do tipo
        ,tlm_cd_periodo                      = '-'
        ,tlm_cd_risco_ajudante               = NULL
        ,tlm_cd_quantidade_pacotes           = MLR.totalpacotes
        ,tlm_cd_pontos                       = MLR.Quantidadepontos
        ,tlm_ds_observacao                   = PFD.Descricao
        ,tlm_cd_cliente                      = plm_cd_cliente
        ,tlm_in_ativo                        = 1  --- não aceita null
        ,tlm_in_excluido                     = 0  --- não aceita null
        ,tlm_cd_usuario_criacao              = 7 
        ,tlm_dh_criacao                      = GETDATE()
        ,tlm_cd_usuario_modificacao          = 7 
        ,tlm_dh_modificacao                  = GETDATE()
        ,tlm_cd_transportadora               = PFD.idtransportadora
        ,tlm_in_marketplace                  = NULL
        ,tlm_ds_motorista_apoio              = NULL
        ,tlm_tipo_valor_apoio                = NULL
        ,tlm_vl_valor_apoio                  = NULL
        ,tlm_cd_tipo_veiculo_nao_utilizado   = NULL
        ,tlm_dh_nao_utilizado                = NULL
        ,tlm_dh_referencia                   = PFD.DataQuinzena 
        ,tlm_cd_arquivo                      = NULL
        ,tlm_cd_cliente_transportadora       = plm_cd_cliente_transportadora --vem desta tabela, aproveita o cruzamento que insere na tb_tipos_lancamentos_manuais select lst_cd_lista,* from tb_lista where lst_nm_lista = 'Clientes transportadoras'
        ,tlm_vl_valor_rota                   = NULL 
        ,tlm_vl_valor_adicional              = NULL
        ,tlm_ds_motorista_secundario         = NULL
        ,tlm_vl_valor_descontos              = pfd.total-- tb_fin_prefatura_descontos
        ,tlm_ds_matricula                    = NULL
        ,tlm_ds_placa                        = Placa
        ,tlm_cd_mot                          = PFD.UsuarioDA
        ,tlm_cd_mot_apoio                    = NULL
        ,tlm_tp_credito_debito               = NULL
		,tlm_cd_operacao					 = @Operacao
 FROM tb_fin_prefatura_descontos AS PFD
left JOIN tb_ml_rotas AS MLR ON CAST(PFD.idrota AS VARCHAR) = CAST(MLR.idrota AS VARCHAR)
left join tb_bases as bss on mlr.OrigemSaida = bss.bss_ds_sigla and mlr.IdTransportadora = bss.bss_cd_idtransportadora and bss.bss_espelho_xpt = 1
LEFT JOIN tb_veiculos v WITH(NOLOCK)
                    ON v.vei_cd_cliente = @Cliente
                    AND MLR.Placa = v.vei_ds_placa
                    AND v.vei_in_ativo = 1
                    AND v.vei_in_excluido = 0
                    
left join ( select
				 plm_cd_tipo_lancamento_manual
				,plm_cd_cliente_transportadora
				,plm_cd_cliente
				,lst_cd_lista
				,cli_id_logistics
				,plm_nm_tipo
				,case when plm_nm_tipo = 'PF - PNR' then 1
					  when plm_nm_tipo = 'PF - Pacote Perdido' then 2
					  when plm_nm_tipo = 'PF - Endereço não visitado' then 3
					  else 0 end as idPenalidade
				from tb_tipos_lancamentos_manuais LM
				join (
							select distinct *
							from tb_lista
							where lst_nm_lista = 'Clientes transportadoras' and lst_ds_label = 'Mercado Livre'
							) as LsT on LM.plm_cd_cliente_transportadora = lst.lst_cd_lista
				left join (
							Select distinct 
							cli_cd_codigo_cliente
							,cli_id_logistics
							from tb_clientes
				) as LG on LM.plm_cd_cliente = LG.cli_cd_codigo_cliente
				where plm_nm_tipo in ('PF - Pacote Perdido','PF - PNR','PF - Endereço não visitado')
					
) CDs on PFD.idPenalidade	   = Cds.idPenalidade
	 and pfd.IdTransportadora  = Cds.cli_id_logistics

    WHERE 1=1
		and PFD.IdTransportadora = @IdTransportadora
		and PFD.Ano = @Ano
		and PFD.Mes = @Mes
		and PFD.Quinzena = @Quinzena
		and plm_cd_cliente not in (7,11)
		and Isnull(mlr.Excluido,0) = 0
        and PFD.UsuarioDA is not null --não insere lançamentos em que não teve usuário DA
		--and mlr.StatusRota <> 'planned'  
	    and isnull(mlr.excluido,0) = 0
        and mlr.statusrota <> 'planned'
		--and plm_cd_tipo_lancamento_manual is not null 
		--and MLR.idrota is not null
		--and plm_cd_cliente is not null
		--and mlr.excluido = 0

      AND NOT EXISTS (
          SELECT 1 
          FROM tb_lancamentos_manuais LM
          WHERE cast(LM.tlm_cd_rota as varchar) = cast(MLR.idrota as varchar)
            AND LM.tlm_ds_observacao = PFD.Descricao
			and tlm_cd_operacao = @Operacao
            and tlm_cd_service_center = COALESCE(v.vei_ds_base_espelho,CASE WHEN bss.bss_espelho_xpt = 1 THEN mlr.OrigemSaida ELSE MLR.ServiceCenter END)
      )
	  ;




--Etapa 6: insert into tb_aprovacao_lancamento_manual
insert into tb_aprovacao_lancamento_manual ( alm_cd_lancamento_manual,
    alm_ds_status,    alm_ds_motivo,    alm_cd_usuario_aprovacao,    alm_dh_aprovacao,    alm_cd_cliente,
    alm_in_ativo,    alm_in_excluido,    alm_cd_usuario_criacao,    alm_dh_criacao,    alm_cd_usuario_modificacao,
    alm_dh_modificacao,    alm_cd_chave_reprovacao,    alm_ds_observacao_reprovacao )

SELECT
    tlm.tlm_cd_lancamento_manual         AS alm_cd_lancamento_manual,
    case
        when @NotVisited  = 1 and tlm.tlm_ds_observacao LIKE ('%Vehicle Daily Not Visited%') then 'Aprovado' 
        when @LostPackges = 1 and tlm.tlm_ds_observacao LIKE ('%Lost Packages Penalty%')     then 'Aprovado' 
        when @Pnr         = 1 and tlm.tlm_ds_observacao LIKE ('%Pnr Packages Penalty%')      then 'Aprovado' 
        
    else 'Aguardando Aprovação' end AS alm_ds_status,

    ''                                   AS alm_ds_motivo,
    NULL                                 AS alm_cd_usuario_aprovacao,
    NULL                                 AS alm_dh_aprovacao,
    tlm.tlm_cd_cliente                   AS alm_cd_cliente,
    1                                    AS alm_in_ativo,
    0                                    AS alm_in_excluido,
    7                                    AS alm_cd_usuario_criacao,
    GETDATE()                            AS alm_dh_criacao,
    7                                    AS alm_cd_usuario_modificacao,
    GETDATE()                            AS alm_dh_modificacao,
    NULL                                 AS alm_cd_chave_reprovacao,
    NULL                                 AS alm_ds_observacao_reprovacao

FROM tb_lancamentos_manuais tlm WITH (NOLOCK)
WHERE 1=1
and tlm.tlm_cd_cliente not in (7,11)
and (tlm.tlm_ds_observacao LIKE ('%Lost Packages Penalty%')
or tlm.tlm_ds_observacao LIKE ('%Pnr Packages Penalty%')
or tlm.tlm_ds_observacao LIKE ('%Vehicle Daily Not Visited%')
)
  AND NOT EXISTS (
        SELECT 1
        FROM tb_aprovacao_lancamento_manual alm WITH (NOLOCK)
        WHERE alm.alm_cd_lancamento_manual = tlm.tlm_cd_lancamento_manual
  );

  /*

select top 100 * from tb_lancamentos_manuais where tlm_cd_rota = '218094374'
and tlm_cd_lancamento_manual = 110095
  
select top 100 * from  tb_aprovacao_lancamento_manual where alm_cd_lancamento_manual = 110095

Select distinct *from tb_clientes


UPDATE LM
SET LM.tlm_dh_referencia = PFD.DataQuinzena
FROM tb_lancamentos_manuais LM WITH (NOLOCK)
INNER JOIN tb_fin_prefatura_descontos AS PFD WITH (NOLOCK)
    ON CAST(LM.tlm_cd_rota AS VARCHAR) = CAST(PFD.idrota AS VARCHAR)
   AND LM.tlm_ds_observacao = PFD.Descricao


  */
 

--END;


--select *  from tb_fin_prefatura_descontos
--where IdTransportadora	 = 1731064496
--and Ano	                 = 2025
--and Mes	                 = 08
--and Quinzena             = 1


--select * 
--from tb_tipos_lancamentos_manuais
--where plm_cd_tipo_lancamento_manual in (
--308,344,380
--)


--select * from tb_tipos_lancamentos_manuais
--where plm_nm_tipo = 'PF - Pacote Perdido'

GO
