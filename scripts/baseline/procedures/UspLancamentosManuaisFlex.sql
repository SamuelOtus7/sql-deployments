-- ============================================================
-- BASELINE: dbo.UspLancamentosManuaisFlex
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLancamentosManuaisFlex]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    Este script realiza a integração de lançamentos manuais de abastecimento a partir de eventos integrados,
    garantindo que apenas motoristas cadastrados na tabela de usuários sejam considerados e evitando duplicidades.
    
    Passos principais:
    1. Remove a tabela temporária #tb_lancamentos_manuais caso já exista.
    2. Cria a tabela temporária #tb_lancamentos_manuais com dados de abastecimento integrados, 
       associando motoristas apenas se estiverem na tabela de usuários.
    3. Insere na tabela principal tb_lancamentos_manuais apenas os lançamentos que ainda não existem, 
       prevenindo duplicidade com base no código do evento.
    4. Insere registros de aprovação automática na tabela tb_aprovacao_lancamento_manual para os lançamentos inseridos,
       marcando como 'Aprovado' para clientes específicos.
    
    Comentários futuros:
    - Caso o motorista nao esteja cadastro(cpf na tb motorista), como devemos sinalizar para que ele apareca nos lancamentos manuais?
        ter um alerta se tem motirsta na flex que nao esta cadastrado. 

    - Para verificar duplicaidade, precisamos de uma coluna de codigo do evento na tabela de lançamentos manuais.

    Entendimento do luiza:
    - Todos o lanamentos sao descontos manuais
    - todas os motoristas que tem desconto da flex tem desconto no cartao
    - usou flex desconta os 10 reais? 
        Resposta: 10 reais por espelho gerado nos adicionais
    - fazer o filtro de desconto flex na tb_motorista.
        Resposta: feito
    - qual sera a base de teste?
        Resposta: testa tudo em porducao.

--lancamento manual sem rota nao aparce como um lancamento
--*/
CREATE procedure [dbo].[UspLancamentosManuaisFlex]
as

declare @data_inicio date = cast(getdate()-15 as date),
        @data_fim date = cast(getdate() as date)


        


-- Remove a tabela temporária se já existir


drop table if exists #tb_integracao_flex_eventos;
select
    ROW_NUMBER() over (partition by iev_cd_motorista_cpf, iev_nm_hodometro_anterior,cast(iev_dh_data_hora_evento as date) order by iev_dh_data_hora_evento) as row_num
    , *
into #tb_integracao_flex_eventos
from tb_integracao_flex_eventos
where 1=1
    -- and iev_ds_nome_motorista = 'DANILO ALVES'
    and cast(iev_dh_data_hora_evento as date) >= @data_inicio
    and cast(iev_dh_data_hora_evento as date) <= @data_fim
    and iev_cd_codigo_cliente in (  select  prm_cod_cliente
                                    from    tb_parametros as a
                                    where   prm_ds_categoria = 'Integração Flex Rotas'
                                            and prm_nm_parametro = 'Integração Habilitada FlexRotas'
                                            and prm_ds_valor = 'true')
order by iev_dh_data_hora_evento

drop table if exists #tb_lancamentos_manuais
-- Cria uma tabela temporária com os lançamentos manuais a partir dos eventos integrados
select
    iev_cd_codigo_evento,
    iev_dh_data_hora_evento_utc as tlm_dh_referencia,
    plm_cd_tipo_lancamento_manual as tlm_cd_tipo,
    usr_nm_usuario as tlm_cd_motorista,
    'Cod: ' + cast(iev_cd_codigo_evento as varchar(15)) + ' O cartão número ' + iev_cd_numero_cartao +
        ' foi utilizado no ' + iev_ds_rede_posto +
        ' para abastecimento de ' + 
        FORMAT(iev_nm_qtde_litros, 'N2') + ' litros, ao valor unitário de R$ ' +
        FORMAT(iev_nm_valor_unitario, 'N2') + '.' AS tlm_ds_observacao,
    iev_ds_placa as tlm_ds_placa,
    iev_nm_valor_abastecido as tlm_vl_valor_descontos,
    1 as tlm_in_ativo,
    0 as tlm_in_excluido,
    7 as tlm_cd_usuario_criacao,
    GETDATE() as tlm_dh_criacao,
    7 as tlm_cd_usuario_modificacao,
    GETDATE() as tlm_dh_modificacao,
    iev_cd_codigo_cliente as tlm_cd_cliente,
    cli.cli_id_logistics as tlm_cd_transportadora,
    lst.lst_cd_lista as tlm_cd_operacao,
    usr_cd_usuario as tlm_cd_mot
--esta coluna precisa ser crianda em producao

into #tb_lancamentos_manuais

from #tb_integracao_flex_eventos as a
    join tb_motorista m on a.iev_cd_motorista_cpf = m.mot_cpf
                        and m.mot_cd_cliente = a.iev_cd_codigo_cliente
                        and m.mot_cpf <> ''
                        and m.mot_cd_status = 1
    join tb_usuario as b on m.mot_cd_usuario = b.usr_cd_usuario
                        
    left join tb_tipos_lancamentos_manuais as lanc
    on a.iev_cd_codigo_cliente = lanc.plm_cd_cliente
        and plm_nm_tipo = 'Abastecimento Integrado'
    inner join tb_clientes as cli
    on a.iev_cd_codigo_cliente = cli.cli_cd_codigo_cliente
    inner join tb_lista as lst
    on a.iev_cd_codigo_cliente = lst.lst_cd_cliente
        and lst_nm_lista = 'Operações Marketplace'
        and lst_ds_valor = 'LM'
  

where iev_cd_codigo_cliente in (select  prm_cod_cliente
                                from    tb_parametros as a
                                where   prm_ds_categoria = 'Integração Flex Rotas'
                                        and prm_nm_parametro = 'Integração Habilitada FlexRotas'
                                        and prm_ds_valor = 'true')
--AND row_num = 1
and usr_in_ativo = 1
and mot_desconto_flex_frota = 1
    -- and mot_nm_svc in ('SSP10','SSP12','SSP28','SSP04')
and cast(iev_dh_data_hora_evento_utc as date) between @data_inicio and @data_fim


-- select * from #tb_lancamentos_manuais
-- select *  from tb_lancamentos_manuais where tlm_cd_motorista = 'elisangela cristina gomes medeiros'

 --Insere na tabela principal apenas os lançamentos que ainda não existem (evita duplicidade)
INSERT INTO tb_lancamentos_manuais
    (
    tlm_dh_referencia,
    tlm_cd_tipo,
    tlm_cd_motorista,
    tlm_ds_observacao,
    tlm_ds_placa,
    tlm_vl_valor_descontos,
    tlm_in_ativo,
    tlm_in_excluido,
    tlm_cd_usuario_criacao,
    tlm_dh_criacao,
    tlm_cd_usuario_modificacao,
    tlm_dh_modificacao,
    tlm_cd_cliente,
    tlm_cd_transportadora,
    tlm_cd_operacao,
    tlm_cd_mot
    )


select
    a.tlm_dh_referencia,
    a.tlm_cd_tipo,
    a.tlm_cd_motorista,
    a.tlm_ds_observacao,
    a.tlm_ds_placa,
    a.tlm_vl_valor_descontos,
    a.tlm_in_ativo,
    a.tlm_in_excluido,
    a.tlm_cd_usuario_criacao,
    a.tlm_dh_criacao,
    a.tlm_cd_usuario_modificacao,
    a.tlm_dh_modificacao,
    a.tlm_cd_cliente,
    a.tlm_cd_transportadora,
    a.tlm_cd_operacao,
    a.tlm_cd_mot

from #tb_lancamentos_manuais as a

   
    left join (
        -- Extrai o código do evento dos lançamentos já existentes para evitar duplicidade
        select
        SUBSTRING(
                a.tlm_ds_observacao,
                CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5,
                CHARINDEX(' ', a.tlm_ds_observacao, CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5) - (CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5)
            ) as iev_cd_codigo_evento,
        *
    from tb_lancamentos_manuais as a
    where left(tlm_ds_observacao, 5) = 'Cod: '
    ) as b
    on 1=1
    and a.tlm_cd_cliente       = b.tlm_cd_cliente 
    and a.tlm_cd_motorista     = b.tlm_cd_motorista
    and cast(a.tlm_dh_referencia as date)   = cast(b.tlm_dh_referencia as date)
    and a.tlm_vl_valor_descontos        = b.tlm_vl_valor_descontos

    where b.iev_cd_codigo_evento is null
   
-- and mot.mot_cd_status = 1

-- Insere registros de aprovação automática para os lançamentos inseridos
insert into tb_aprovacao_lancamento_manual
    (
    alm_cd_lancamento_manual,
    alm_ds_status,
    alm_ds_motivo,
    alm_cd_usuario_aprovacao,
    alm_dh_aprovacao,
    alm_cd_cliente,
    alm_in_ativo,
    alm_in_excluido,
    alm_cd_usuario_criacao,
    alm_dh_criacao,
    alm_cd_usuario_modificacao,
    alm_dh_modificacao,
    alm_cd_chave_reprovacao,
    alm_ds_observacao_reprovacao
    )

select
    tlm.tlm_cd_lancamento_manual as alm_cd_lancamento_manual,
    case when prm.prm_ds_valor = 'true' then 'Aprovado' else 'Aguardando Aprovação' end as alm_ds_status,
    --case when tlm.tlm_cd_cliente in (37) then 'Aprovado' else 'Aguardando Aprovação' end as alm_ds_status,
    '' as alm_ds_motivo,
    NULL as alm_cd_usuario_aprovacao,
    NULL as alm_dh_aprovacao,
    tlm.tlm_cd_cliente as alm_cd_cliente,
    1 as alm_in_ativo,
    0 as alm_in_excluido,
    7 as alm_cd_usuario_criacao,
    GETDATE() as alm_dh_criacao,
    7 as alm_cd_usuario_modificacao,
    GETDATE() as alm_dh_modificacao,
    NULL as alm_cd_chave_reprovacao,
    NULL as alm_ds_observacao_reprovacao
from tb_lancamentos_manuais tlm with (nolock)
    left join tb_aprovacao_lancamento_manual as alm
    on alm.alm_cd_lancamento_manual = tlm.tlm_cd_lancamento_manual
    left join tb_parametros as prm on tlm.tlm_cd_cliente = prm.prm_cod_cliente
                                    and prm_ds_categoria = 'Integração Flex Rotas'
                                    and prm_nm_parametro = 'Aprovação Automática'
where tlm.tlm_in_excluido = 0
    and tlm_ds_observacao like '%O cartão número%abastecimento%'
    and alm.alm_cd_lancamento_manual  is null




----cancela lancamentos excluidos da eventos
--update apv 
--set   apv.alm_ds_status =  case when a.tlm_cd_cliente in (37) then 'Aprovado'  else 'Aguardando Aprovação' end 

--from tb_lancamentos_manuais as a

--    left join tb_motorista as mot
--    on a.tlm_cd_motorista = mot.mot_nm_motorista
--        and a.tlm_cd_cliente = mot.mot_cd_cliente


--    left join (
--        -- Extrai o código do evento dos lançamentos já existentes para evitar duplicidade
--     select
--        *
--    from #tb_lancamentos_manuais as a
--    where left(tlm_ds_observacao, 5) = 'Cod: '
--    ) as b
--    on SUBSTRING(
--                a.tlm_ds_observacao,
--                CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5,
--                CHARINDEX(' ', a.tlm_ds_observacao, CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5) - (CHARINDEX('Cod: ', a.tlm_ds_observacao) + 5)
--            ) = b.iev_cd_codigo_evento

--    join tb_aprovacao_lancamento_manual as apv
--    on a.tlm_cd_lancamento_manual =  apv.alm_cd_lancamento_manual

--where b.iev_cd_codigo_evento is null
--and mot_desconto_flex_frota = 1
--and cast(a.tlm_dh_referencia as date) between @data_inicio and @data_fim
--and a.tlm_cd_tipo = 440
--and a.tlm_cd_cliente = 37





GO
