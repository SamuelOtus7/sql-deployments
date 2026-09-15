-- ============================================================
-- BASELINE: dbo.UspSPEFinOrigemRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEFinOrigemRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPEFinOrigemRotas]   (
    @CodPeriodoPagamento int,
    @cd_usr int,
    @idrota varchar(50) = null
)
as

begin

  declare
    @IdTransportadora int,
    --@CodPeriodoPagamento int = 2605,
    --@idrota varchar(50) = null,
    --@cd_usr int = 7, --  se receber valor null precisa
    @data_inicial date,
    @data_final date,
    @clienteid int,
    @usuarioIrisys int,
    @Motorista varchar(250),
    @IdCliTransportadora int,
    @tipocontrato int = null,
    @agora datetime =  getdate()


    ----- parametros de filtros
    set @data_inicial = (
    select pgp_dt_inicio
    from [dbo].[tb_pgto_periodo] with (nolock)
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    set @data_final = (
    select pgp_dt_fim
    from [dbo].[tb_pgto_periodo] with (nolock)
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    if @idrota is not null
begin
        set @Motorista = (
        select distinct motorista
        from tb_spe_rotas_v5 (nolock)
        where CodigoRota = @idrota
    )
    end

    set @IdTransportadora = (
    select cli_id_shopee
    from [tb_pgto_periodo] as a (nolock)
        left join tb_clientes as b (nolock)
        on a.pgp_cd_cliente = cli_cd_codigo_cliente
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    set @tipocontrato = (
    select pgp_cd_tipo_contratos
    from [tb_pgto_periodo] as a (nolock)
        left join tb_clientes as b (nolock)
        on a.pgp_cd_cliente = cli_cd_codigo_cliente
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    set @IdCliTransportadora = (
    select lst_cd_lista
    from tb_lista (nolock)
    where lst_nm_lista = 'Clientes transportadoras'
        and lst_ds_label = 'Shopee'
        and lst_cd_cliente in (
            select pgp_cd_cliente
        from [tb_pgto_periodo] as a (nolock)
            left join tb_clientes as b (nolock)
            on a.pgp_cd_cliente = cli_cd_codigo_cliente
        where pgp_cd_periodo = @CodPeriodoPagamento
        )
)

    set @clienteid = (
    select pgp_cd_cliente
    from [tb_pgto_periodo] as a (nolock)
        left join tb_clientes as b (nolock)
        on a.pgp_cd_cliente = cli_cd_codigo_cliente
    where pgp_cd_periodo = @CodPeriodoPagamento
)

    declare @Operacao int = (   
    select  pgp_tipo_operacao
    from    [tb_pgto_periodo] as a with(nolock)
    where   pgp_cd_periodo = @CodPeriodoPagamento   
    
		)

    declare @TipoOperacao varchar(2) = (   
    
                select  lst_ds_valor
                from    tb_lista as a with(nolock)
                inner   join [tb_pgto_periodo] as b with(nolock)
                        on a.lst_cd_cliente = b.pgp_cd_cliente
                        and a.lst_cd_lista = b.pgp_tipo_operacao
                where   lst_nm_lista = 'Operações Marketplace'
                        and pgp_cd_periodo = @CodPeriodoPagamento   
    
		)

     declare @DataPrevistaPagamento date = (  
      
		select pgp_dt_prevista_pagamento  
		from [tb_pgto_periodo] as a (NOLOCK)  
		where pgp_cd_periodo  = @CodPeriodoPagamento
     
		)

    ----- parametros para calculos
    declare @Kmselecionado1 varchar(150) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
        and prm_nm_parametro = 'Km a ser utilizado.'
        and prm_cod_cliente = @clienteid
)

    declare @Kmselecionado2 varchar(150) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'
        and prm_nm_parametro = 'Km a ser utilizado 2'
        and prm_cod_cliente = @clienteid
)

    declare @MenorValorKm VARCHAR(5) = (
    select prm_ds_valor
    from tb_parametros
    where prm_nm_parametro = 'Considerar menor valor entre KM'
        and prm_cod_cliente = @clienteid
)

declare @ParamKmMinimo varchar(50) = lower(ltrim(rtrim(isnull(
															(select 
																prm_ds_valor
															from 
																tb_parametros with(nolock)
															where 
																prm_nm_parametro = 'Aplicar Km mínimo'
																and prm_in_ativo = 1
																and prm_in_excluido = 0
																and prm_cod_cliente = @clienteid
															)
														,'false'))))

    declare @Veiculo varchar(50) = (
    select lst_ds_label
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Veiculo'
        and prm_cod_cliente = @clienteid
        and prm_cod_operacao = @IdCliTransportadora
)

    -- utiliza ponto ou parada
    declare @PontoOuParada varchar(50) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Pontou ou Parada'
        and prm_cod_cliente = @clienteid
)

    -- este parametro e a origem da parada
    declare @OrigemParada varchar(50) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    -- o nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Paradas"
    where l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadeParadas'
        and prm_cod_cliente = @clienteid
)

    -- origem oponto
    declare @OrigemPonto varchar(50) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    -- o nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Pontos"
    where l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadePontos'
        and prm_cod_cliente = @clienteid
)

    declare @DivisaoEspelho varchar(50) = (
    select prm_ds_valor
    from tb_parametros
    where prm_nm_parametro = 'Divisão  de espelho'
        and prm_cod_cliente = @clienteid
    )

    -- descontos de ponto ou parada
    declare @DescontaPontoPara varchar(50) = (
    select lst_ds_valor
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Desconta Pacote'
        and prm_cod_cliente = @clienteid
)

    ----- regras de calculo
    declare @RegrEscolhaKM VARCHAR(max) = (
    'case when ''' + CAST(@MenorValorKm AS VARCHAR) + ''' = ''true'' and nullif(' + @Kmselecionado1 + ',0) <= ' + @Kmselecionado2 + ' then nullif(' + @Kmselecionado1 + ',0) else isnull(nullif(' + @Kmselecionado1 + ',0), ' + @Kmselecionado2 + ') end'
)

    declare @QuantidadePontoParadas VARCHAR(max) = (
     '( case  when ''' + @PontoOuParada  + ''' = ''Parada'' then ' + @OrigemParada + ' when ''' + @PontoOuParada  + ''' = ''Ponto'' then ' + @OrigemPonto + ' else 0 end) + '' - '' + ' + @DescontaPontoPara + ''
)


set @QuantidadePontoParadas = isnull(@QuantidadePontoParadas,'a.QuantidadeParadas')
set @RegrEscolhaKM = isnull(@RegrEscolhaKM,'a.kmcoletado')
set @Veiculo = isnull(@Veiculo,'a.tipoveiculo')



drop table if exists #tb_pgto_periodo_rota_edit
select *
into #tb_pgto_periodo_rota_edit
from (
select
        *,
        cast(SUBSTRING(edit_Faixa_KM, 1, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(12,4)) as edit_km_selecionado,
        row_number() over(partition by edit_rota order by edit_dh_criacao desc) as ordem
    from tb_pgto_periodo_rota_edit (NOLOCK)
    where edit_cd_periodo =  @CodPeriodoPagamento
) as a
where ordem = 1;







DECLARE @SQL NVARCHAR(MAX) = N'
SELECT DISTINCT
    a.idtransportadora,  
    CAST(@CodPeriodoPagamento AS VARCHAR)  AS ppr_cd_periodo,
    dataReferencia                          AS ppr_data_referencia,
    ISNULL(b.edit_Service_Center, NomeHub)  AS ppr_base_principal,
    ISNULL(edit_cidade, case when @TipoOperacao = ''LH'' then StationDestino else CidadeDistante end) AS [CidadeBase],
    ISNULL(edit_Ciclo_PM,
           CASE WHEN DATEPART(hour, DataHoraInicio) < 12 THEN ''AM'' ELSE ''PM'' END) AS ppr_ds_ciclo,
    ISNULL(b.edit_Placa, a.Placa) AS Placa,
    ISNULL(b.edit_Tipo_Veiculo, CASE WHEN ' + @Veiculo + ' IS NULL THEN a.tipoveiculo ELSE ' + @Veiculo + ' END) AS TipoVeiculo,
    Motorista,
    UsuarioIrisys,
    ISNULL(b.edit_usou_app, a.UsouAPP) AS UsouAPP,
    a.codigorota as ppr_cd_rota,
    ISNULL(b.edit_quantidade_pacotes_entregues, a.PacotesEntregues) AS PacotesEntregues,
    ISNULL(b.edit_Quantidade_Pacotes, a.TotalPacotes)     AS TotalPacotes,
    PacotesNaoEntregue,
    PacotesPendentes,
    --COALESCE(b.edit_km_selecionado, CAST(EditFicha.[vmp_kmpagamento] AS DECIMAL(10,2)), @RegrEscolhaKM) AS KmColetado,
    case when @TipoOperacao = ''LH'' then 1 else coalesce(b.edit_Total_KM,b.edit_km_selecionado,DistanciaTotal,KmPacotes,0) end AS KmColetado,
    ISNULL(feriado.Feriado, 0) AS ppr_in_fer,
    CASE WHEN Domingo.NumDiaSemana = 1 THEN 1 ELSE 0 END AS ppr_in_dom,
    CASE WHEN Domingo.NumDiaSemana = 7 THEN 1 ELSE 0 END AS ppr_in_sab,
    case when b.edit_zerar_pagamento = 1 then 1 else 0 end ppr_in_zerar_rota
FROM tb_spe_rotas_v5 AS a (NOLOCK)
LEFT JOIN (SELECT * FROM #tb_pgto_periodo_rota_edit (NOLOCK)) AS b
    ON a.codigorota = b.edit_rota
LEFT JOIN (
    SELECT
        cli_id_shopee, a.*
    FROM tb_veiculos AS a (NOLOCK)
    INNER JOIN tb_clientes AS b (NOLOCK)
        ON a.vei_cd_cliente = b.cli_cd_codigo_cliente
) AS veiculo
    ON a.idtransportadora = veiculo.cli_id_shopee
   AND a.Placa = veiculo.vei_ds_placa

LEFT JOIN tb_validacao_mapas AS EditFicha
    ON a.codigorota = EditFicha.vmp_cd_rota
LEFT JOIN vw_feriados AS feriado
    ON a.dataReferencia   = feriado.[Data]
   AND a.IdTransportadora = feriado.idtransportadora
LEFT JOIN dimdata AS Domingo
    ON CAST(a.datahorainicio AS date) = Domingo.[data]
left JOIN tb_motorista AS mot
    ON a.UsuarioIrisys = mot_cd_usuario
WHERE a.datareferencia BETWEEN @data_inicial AND @data_final
  AND a.idtransportadora = @IdTransportadora
  AND a.excluido = 0
  and (mot_ctn_cd_tipo_contrato = ' + CONVERT(VARCHAR(10), @tipocontrato)  + ' or ' + CONVERT(VARCHAR(10), @tipocontrato)  + ' = ''-1'')
  and a.TipoOperacao = @TipoOperacao;
';

drop table if exists #tabela;
    create table #tabela
    (
     idtransportadora       int
    ,ppr_cd_periodo         int
    ,ppr_data_referencia    date
    ,ppr_base_principal     varchar(50)
    ,CidadeBase             varchar(50)
    ,ppr_ds_ciclo           varchar(5)
    ,Placa                  varchar(20)
    ,TipoVeiculo            varchar(50)
    ,Motorista              varchar(200)
    ,UsuarioIrisys          int
    ,UsouAPP                varchar(5)
    ,ppr_cd_rota             varchar(50)
    ,PacotesEntregues       int
    ,TotalPacotes           int
    ,PacotesNaoEntregue     int
    ,PacotesPendentes       int
    ,ppr_total_km           decimal(10,2)
    ,ppr_in_fer             int
    ,ppr_in_dom             int
    ,ppr_in_sab             int
    ,ppr_in_zerar_rota      bit
)

insert into #tabela
EXEC sp_executesql
    @stmt = @SQL,
    @params = N'
        @CodPeriodoPagamento VARCHAR(30),
        @data_inicial        DATE,
        @data_final          DATE,
        @TipoOperacao        VARCHAR(2),
        @IdTransportadora    INT
    ',
    @CodPeriodoPagamento = @CodPeriodoPagamento,
    @data_inicial        = @data_inicial,
    @data_final          = @data_final,
    @TipoOperacao        = @TipoOperacao,
    @IdTransportadora    = @IdTransportadora;


    --Caso não tenha sido coletado km, considera o km igual a 1 caso tenha sido parametrizado a regra para transportadora
	if @ParamKmMinimo = 'true'
	begin
        update
            #tabela
        set
            ppr_total_km = 1
        where
            ppr_total_km = 0 or ppr_total_km is null
	end


     update a
    set ppr_base_principal = case
        when a.idtransportadora = @clienteid and @DivisaoEspelho = 'true' then a.ppr_base_principal
        else b.ppr_base_principal
    end
    from #tabela as a
        left join (
        select
            Motorista,
            ppr_base_principal, --repassar esta regra com o saulo pois ja existe uma tratativa ba coluna na no insert da tabela tb_ml_rotas
            row_number() over(partition by Motorista order by count(*) desc) as ordem
        from #tabela
        group by Motorista,ppr_base_principal
    ) as b
        on a.Motorista = b.Motorista
    where b.ordem = 1;

    -- /*consolida os motoristas para gerar o codigo dos espelhos*/
    drop table if exists #espelho;
    select
        distinct
        UsuarioIrisys as mtn_cd_motorista,
        Motorista as mtn_nome_motorista,
        @CodPeriodoPagamento as mtn_cd_pgto_periodo,
        228 mtn_cd_status, -- 228 e o status de Em Apuracao
        0 as mtn_vl_nfs,
        null mtn_ds_link_nfs,
        dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao, --precisa ser um parametro na pgto_periodo_rota
        @agora mtn_dh_criacao,
        @cd_usr mtn_cd_usr_criacao,
        @agora mtn_dh_modificacao,
        @cd_usr mtn_cd_usr_modificacao,
        0 as mtn_in_excluido,
        periodo.pgp_cd_cliente as mtn_cod_cliente,
        count(*) as mtn_qt_rotas,
        94  as mtn_cd_tipo_espelho, -- preciso entender que codigo e este
        @IdCliTransportadora as mtn_cd_cliente_transportadora,
        bss_cd_base as mtn_cd_base,
        ppr_base_principal as mtn_base_principal,
        mot.mot_ctn_cd_tipo_contrato as mtn_cd_tipo_contrato -- precisa criar regra, se o tipo de contrato mudar, precisa excluir o antigo e inserir o novo.

    into #espelho
    from #tabela as a
        left join [tb_pgto_periodo] as periodo (NOLOCK)
        on @CodPeriodoPagamento = periodo.pgp_cd_periodo
        left join tb_clientes (NOLOCK) AS CLI
        ON CLI.cli_cd_codigo_cliente = periodo.pgp_cd_cliente
        left join tb_bases as c (NOLOCK)
        on a.ppr_base_principal = c.bss_ds_sigla
        and a.idtransportadora = c.bss_cd_idtransportadora
        left join tb_motorista as mot
        on UsuarioIrisys = mot.mot_cd_usuario
    WHERE pgp_cd_status = 1 -- se e pgp_in_excluido ou pgp_cd_status
    GROUP BY
    UsuarioIrisys,
    Motorista,
    bss_cd_base,
    ppr_base_principal,
    periodo.pgp_cd_cliente,
    mot.mot_ctn_cd_tipo_contrato



    -- esta etapa insere ou atualiza os dados na tabela de espelhos de pagamento
MERGE tb_pag_espelhos AS target
USING (
    SELECT
        mtn_cd_motorista,
        mtn_nome_motorista,
        mtn_cd_pgto_periodo,
        mtn_cd_status,
        mtn_vl_nfs,
        mtn_ds_link_nfs,
        mtn_dt_prazo_contestacao,
        mtn_dh_criacao,
        mtn_cd_usr_criacao,
        mtn_dh_modificacao,
        mtn_cd_usr_modificacao,
        mtn_in_excluido,
        mtn_cod_cliente,
        case when mtn_qt_rotas > 255 then 255 else mtn_qt_rotas end mtn_qt_rotas,
        mtn_cd_tipo_espelho,
        mtn_cd_cliente_transportadora,
        mtn_cd_base,
        mtn_base_principal,
        @Operacao AS mtn_cd_operacao,
        @DataPrevistaPagamento mtn_dt_prevista_pagamento
        --,
        --mtn_cd_tipo_contrato
    -- este campo e novo, precisa ser criado na tabela tb_pag_espelhos

    FROM #espelho  where mtn_nome_motorista IS NOT NULL
) AS source
ON (
    target.mtn_nome_motorista = source.mtn_nome_motorista
        AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
        AND target.mtn_in_excluido = 0
        AND source.mtn_base_principal = target.mtn_base_principal
)
WHEN MATCHED AND target.mtn_cd_status IN (34,228,38) THEN
    UPDATE SET
        mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao,
        mtn_dh_modificacao = source.mtn_dh_modificacao,
        mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao,
        mtn_cod_cliente = source.mtn_cod_cliente,
        mtn_qt_rotas = source.mtn_qt_rotas,
        mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho,
        mtn_base_principal = source.mtn_base_principal,
        mtn_cd_base = source.mtn_cd_base,
		mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora,

		--adicionado por Saulo Barros em 03/02/2026 devido a task https://app.clickup.com/t/86aez7j30
		mtn_cd_motorista = source.mtn_cd_motorista,

        --ajuste para atualizar somente quando a data não for atualizada manualmente
        mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end

        --mtn_cd_tipo_contrato = source.mtn_cd_tipo_contrato
WHEN NOT MATCHED THEN
    INSERT (
        mtn_cd_motorista,
        mtn_nome_motorista,
        mtn_cd_pgto_periodo,
        mtn_cd_status,
        mtn_vl_nfs,
        mtn_ds_link_nfs,
        mtn_dt_prazo_contestacao,
        mtn_dh_criacao,
        mtn_cd_usr_criacao,
        mtn_dh_modificacao,
        mtn_cd_usr_modificacao,
        mtn_in_excluido,
        mtn_cod_cliente,
        mtn_qt_rotas,
        mtn_cd_tipo_espelho,
        mtn_cd_cliente_transportadora,
        mtn_cd_base,
        mtn_base_principal,
        mtn_cd_operacao,
        mtn_dt_prevista_pagamento
        --mtn_cd_tipo_contrato
    )
    VALUES (
        source.mtn_cd_motorista,
        source.mtn_nome_motorista,
        source.mtn_cd_pgto_periodo,
        source.mtn_cd_status,
        source.mtn_vl_nfs,
        source.mtn_ds_link_nfs,
        source.mtn_dt_prazo_contestacao,
        source.mtn_dh_criacao,
        source.mtn_cd_usr_criacao,
        source.mtn_dh_modificacao,
        source.mtn_cd_usr_modificacao,
        source.mtn_in_excluido,
        source.mtn_cod_cliente,
        source.mtn_qt_rotas,
        source.mtn_cd_tipo_espelho,
        source.mtn_cd_cliente_transportadora,
        source.mtn_cd_base,
        source.mtn_base_principal,
        source.mtn_cd_operacao,
        source.mtn_dt_prevista_pagamento
    );

    --esta etapa insere ou atualiza os dados na tabela de pagamento de periodo de rota

 MERGE INTO [tb_pgto_periodo_rota] AS target
USING (
    SELECT
        ppr_cd_periodo,
        ppr_cd_rota as ppr_cd_rota,
        null as ppr_cd_faixa_km, --esta coluna precisa sere preenchida na procedure de calculo pois depende da faixa de km da transportadora.
        placa as ppr_ds_placa,
        TipoVeiculo as ppr_ds_tipo_veiculo,
        ppr_ds_ciclo,
        TotalPacotes as ppr_qt_pacotes,
        -- QuantidadePontos as ppr_qt_pontos,
        null as ppr_qt_faixa, --nao existe pagamento de pontos e paradas ao mesmo tempo. inclui como parametro o pagament se para ou ponto. tempos que utilizar uma unica coluna
        0 as ppr_in_area_risco, --infromacao que vira da ficha de rota
        0 as ppr_in_ajudante, --infromacao que vira da ficha de rota
        ppr_in_fer, 
        ppr_in_dom, 
        ppr_in_sab, 
        @agora as ppr_dh_criacao,
        @cd_usr as ppr_cd_usr_criacao,
        @agora as ppr_dh_modificacao,
        @cd_usr as ppr_cd_usr_modificacao,
        1 as ppr_in_ativo,
        0 as ppr_in_excluido,
        UsuarioIrisys as ppr_cd_motorista,
        PacotesEntregues as ppr_qt_pacotes_entregues,
        PacotesPendentes as ppr_qt_pacotes_pendentes,
        b.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs,
        b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho,
        UsouApp as ppr_usou_app,
        ppr_data_referencia,
        b.mtn_base_principal as ppr_base_principal,

        motorista as ppr_nome_motorista,
        CidadeBase as ppr_nm_cidade,
        'SPE' as ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        'Rota Shopee' as ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento (este tambem e novo, precisa ser criado na tb_pgto_periodo_rota)
        ppr_total_km,
        a.ppr_in_zerar_rota,
        1362 as ppr_cd_tipo_pgto

    -- precisa criar esta coluna na tabela tb_pgto_periodo_rota e entender como ia funcionar este calculo com o saulo
    FROM #tabela AS a
        INNER JOIN tb_pag_espelhos AS b (NOLOCK)
        ON a.motorista = b.mtn_nome_motorista
            AND (a.ppr_base_principal = b.mtn_base_principal)
            and ppr_cd_periodo = b.mtn_cd_pgto_periodo
            AND b.mtn_cd_status IN (34,228,38)
            and mtn_in_excluido  = 0
) AS source
ON (
    target.ppr_cd_periodo = source.ppr_cd_periodo
        AND target.ppr_cd_rota = source.ppr_cd_rota
)
WHEN MATCHED THEN
    UPDATE SET
        ppr_ds_placa = source.ppr_ds_placa,
        ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
        ppr_ds_ciclo = source.ppr_ds_ciclo,
        --ppr_qt_faixa = source.ppr_qt_faixa,
        ppr_in_area_risco = source.ppr_in_area_risco,
        ppr_in_ajudante = source.ppr_in_ajudante,
        ppr_in_fer = source.ppr_in_fer,
        ppr_in_dom = source.ppr_in_dom,
        ppr_in_sab = source.ppr_in_sab,
        ppr_dh_modificacao = @agora, -- preciso criar um parametro para a data de modificacao
        ppr_cd_usr_modificacao = @cd_usr, -- preciso criar um parametro para o usuario que esta executando o processo
        ppr_cd_motorista = source.ppr_cd_motorista,
        ppr_qt_pacotes = source.ppr_qt_pacotes,
        ppr_qt_pacotes_entregues = source.ppr_qt_pacotes_entregues,
        ppr_qt_pacotes_pendentes = source.ppr_qt_pacotes_pendentes,
        ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
        ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
        ppr_usou_app = source.ppr_usou_app,
        ppr_data_referencia = source.ppr_data_referencia,
        ppr_base_principal = source.ppr_base_principal,
        --ppr_tipo_rota = source.ppr_tipo_rota,
        ppr_nome_motorista = source.ppr_nome_motorista,
        ppr_nm_cidade = source.ppr_nm_cidade,
        ppr_total_km = source.ppr_total_km,
        ppr_in_zerar_rota = source.ppr_in_zerar_rota,
        ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto
        --ppr_enderecos_visitados = source.ppr_enderecos_visitados

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        ppr_cd_periodo,
        ppr_cd_rota,
        ppr_ds_placa,
        ppr_ds_tipo_veiculo,
        ppr_ds_ciclo,
        ppr_qt_pacotes,
        --ppr_qt_faixa,
        ppr_in_area_risco,
        ppr_in_ajudante,
        ppr_in_fer,
        ppr_in_dom,
        ppr_in_sab,
        ppr_dh_criacao,
        ppr_cd_usr_criacao,
        ppr_dh_modificacao,
        ppr_cd_usr_modificacao,
        ppr_in_ativo,
        ppr_in_excluido,
        ppr_cd_motorista,
        ppr_qt_pacotes_entregues,
        ppr_qt_pacotes_pendentes,
        ppr_cd_motorista_nfs,
        ppr_cd_pgto_espelho,
        ppr_usou_app,
        ppr_data_referencia,
        ppr_base_principal,
        --ppr_tipo_rota,
        ppr_nome_motorista,
        ppr_nm_cidade,
        ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
        ppr_total_km,
        ppr_in_zerar_rota,
        ppr_cd_tipo_pgto
        --ppr_enderecos_visitados --precisa criar esta coluna na tabela tb_pgto_periodo_rota e entender como ia funcionar este calculo com o saulo
    )
    VALUES (
        source.ppr_cd_periodo,
        source.ppr_cd_rota,
        source.ppr_ds_placa,
        source.ppr_ds_tipo_veiculo,
        source.ppr_ds_ciclo,
        source.ppr_qt_pacotes,
        --source.ppr_qt_faixa,
        source.ppr_in_area_risco,
        source.ppr_in_ajudante,
        source.ppr_in_fer,
        source.ppr_in_dom,
        source.ppr_in_sab,
        source.ppr_dh_criacao,
        source.ppr_cd_usr_criacao,
        source.ppr_dh_modificacao,
        source.ppr_cd_usr_modificacao,
        source.ppr_in_ativo,
        source.ppr_in_excluido,
        source.ppr_cd_motorista,
        source.ppr_qt_pacotes_entregues,
        source.ppr_qt_pacotes_pendentes,
        source.ppr_cd_motorista_nfs,
        source.ppr_cd_pgto_espelho,
        source.ppr_usou_app,
        source.ppr_data_referencia,
        source.ppr_base_principal,
        --source.ppr_tipo_rota,
        source.ppr_nome_motorista,
        source.ppr_nm_cidade,
        source.ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        source.ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
        source.ppr_total_km,
        source.ppr_in_zerar_rota,
        source.ppr_cd_tipo_pgto
        );



end
GO
