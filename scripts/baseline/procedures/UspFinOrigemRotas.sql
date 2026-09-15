-- ============================================================
-- BASELINE: dbo.UspFinOrigemRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinOrigemRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinOrigemRotas] (
    @CodPeriodoPagamento int,
    @cd_usr int,
    @idrota varchar(50) = null,
    @CodEspelho INT = NULL
)
as  

set nocount on 


    declare
    @IdTransportadora int,
     --@CodPeriodoPagamento int = 2948,
     --@idrota varchar(50) = null,
     --@cd_usr int = 7, --  se receber valor null precisa
     --@CodEspelho int = NULL,
    @data_inicial date,
    @data_final date,
    @clienteid int,
    @usuarioIrisys int,
    @Motorista varchar(250),
    @IdCliTransportadora int,
    @tipocontrato int = null,
    @fontedados varchar(50),
    @agora datetime =  getdate()


    SET @CodEspelho = CASE WHEN @CodEspelho = 0 or @CodEspelho is null THEN -1 ELSE @CodEspelho END
    SET @idrota     = CASE WHEN @idrota = 0 or @idrota is null THEN -1 ELSE @idrota END


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
        select distinct NomeMotorista
        from tb_ml_rotas (nolock)
        where idrota = @idrota
    )
    end

    set @IdTransportadora = (
    select cli_id_logistics
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
        and lst_ds_label = 'Mercado Livre'
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

    declare @Veiculo varchar(50) = (
    select lst_ds_label
    from tb_lista l (nolock)
        inner join tb_parametros as p
        on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
    where l.lst_nm_lista = 'Parâmetros do financeiro - Veiculo'
        and prm_ds_categoria = 'Financeiro - Pagamentos'
        and prm_cod_cliente = @clienteid
        
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

    set @fontedados = (
        select  lst_ds_valor
        from    tb_lista l (nolock)
        inner   join tb_parametros as p
                on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
        where   l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
                and p.prm_nm_parametro = 'Fonte Valores'
                and p.prm_in_ativo = 1
                and p.prm_in_excluido = 0
                and prm_cod_cliente = @clienteid  
    )


    declare @UtilizaSVC int = (
        select  prm_ds_valor
        from    tb_parametros as p
        where   prm_nm_parametro like 'Service Center Padrão'
                and prm_cod_cliente = @clienteid 
    )

    declare @Ambulancia int = (
        select  prm_ds_valor
        from    tb_parametros as p
        where   prm_nm_parametro like 'Regra Ambulância'
                and prm_cod_cliente = @clienteid
    )

    declare @ParamOrigemAmbulancia varchar(20) = (
        select  
			lst_ds_valor
        from    
			tb_lista l (nolock)
			join tb_parametros p on prm_ds_valor = cast(l.lst_cd_lista as varchar(150))
		where   
			p.prm_nm_parametro = 'Origem Ambulancia'
			and p.prm_cod_cliente = @clienteid
			and p.prm_in_ativo = 1
			and p.prm_in_excluido = 0
			and l.lst_nm_lista = 'Parâmetros do financeiro - Fonte Valores'
		)

    set @ParamOrigemAmbulancia = isnull(@ParamOrigemAmbulancia,'Sem Cadastro')

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
set @UtilizaSVC = isnull(@UtilizaSVC,'0')
set @Ambulancia = isnull(@Ambulancia,'0')


     --select
     --    @RegrEscolhaKM,
     --    @QuantidadePontoParadas,
     --    @data_inicial as data_inicial,
     --    @data_final as data_final,
     --    @IdTransportadora as IdTransportadora,
     --    @CodPeriodoPagamento as CodPeriodoPagamento,
     --    @clienteid as clienteid,
     --    @usuarioIrisys as usuarioIrisys,
     --    @Motorista as Motorista,
     --    @IdCliTransportadora as IdCliTransportadora,
     --    @idrota as idrota,
     --    @tipocontrato as tipocontrato,
     --    @cd_usr as cd_usr,
     --    @agora as agora,
     --    @RegrEscolhaKM as RegrEscolhaKM,
     --    @QuantidadePontoParadas as QuantidadePontoParadas,
     --    @Kmselecionado1 as Kmselecionado1,
     --    @Kmselecionado2 as Kmselecionado2,
     --    @MenorValorKm as MenorValorKm,
     --    @Veiculo as Veiculo,
     --    @PontoOuParada as PontoOuParada,
     --    @OrigemParada as OrigemParada,
     --    @OrigemPonto as OrigemPonto,
     --    @DescontaPontoPara as DescontaPontoPara,
     --    @fontedados as Fonte
     --    @UtilizaSVC as UtilizaSVC;

 
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




    --Etapa de Edit Origem Rotas KM
    --Feito para o cliente alterar a fonte do KM selecionado
    alter table #tb_pgto_periodo_rota_edit add KmEditado decimal(10,4)
    alter table #tb_pgto_periodo_rota_edit add NomeKmEditado varchar(100)
    
    update
        edit
    set
        edit.edit_Total_KM = isnull(case 
                                when lst_ds_label = 'KM do app Irisys'                                  then km.pontosAppRotasTotalKm
                                when lst_ds_label = 'KM latitude e longetude dos Pacotes'               then km.pontosRotasPacotesKm
                                when lst_ds_label = 'Km por trevo a trevo'                              then trv.bkt_vl_km_ideal
                                when lst_ds_label = 'Km do RTT'                                         then rtt.KmRTT
                                when lst_ds_label = 'Faixa km da prefatura'                             then pre.FimIntervalo
                                when lst_ds_label = 'Km do app Irisys ou KM lat e long dos pacotes.'    then isnull(case when km.pontosAppRotasTotalKm = 0 then km.pontosRotasPacotesKm else km.pontosAppRotasTotalKm end,1)
                                when lst_ds_label = 'Km coletado do Silos'                              then r.KmTotal
                             end,0)

      , edit.NomeKmEditado = edit.edit_origem_km
    from    
        vw_ml_rotas as r
        inner join #tb_pgto_periodo_rota_edit as edit
            on r.IdRota = edit.edit_rota 
            and edit.edit_origem_km is not null
        inner join tb_lista as lst 
            on lst.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem' 
            and edit.edit_origem_km = lst.lst_ds_label
        left join tb_ml_processamento_km_rotas as km 
            on r.IdKmProcessado = km.id
        left join vw_prefatura_espelhos as pre
            on r.IdRota = pre.IdRota
            and r.IdTransportadora = pre.IdTransportadora
        left join tb_fin_base_km_trevo as trv
            on r.idtrevo = trv.bkt_cd_base_km_trevo
        left join (
                    SELECT IdRota , cast(KmTotal as decimal(10,4)) KmRTT
                    FROM (
                        SELECT *,
                               ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY quinzena DESC) AS rn
                        FROM tb_ml_bsc_rtt WITH (NOLOCK)
                    ) AS sub
                    WHERE rn = 1
            ) AS rtt on rtt.idrota = r.idrota
    where
        r.datareferencia between @data_inicial and @data_final
        and r.idtransportadora = @IdTransportadora
		and (@CodEspelho is null or edit.edit_cd_espelho = @CodEspelho)





    --Etapa de contingencia do KMTotal no momento apenas para HAWK
    --Inserido dia 29/05/2026 por Gustavo Tavares
    drop table if exists #ContigenciaKM
    select	dhr_cd_cliente Cliente
	    ,	dhr_dt_data DataRef
	    ,	dhr_nr_rota Rota
	    ,	dhr_vl_quilometros_percorridos KmContingencia
	    ,	max(dhr_dh_coleta) dhr_dh_coleta
    into	#ContigenciaKM
    from	tb_dra_historico_rotas as a with(nolock)
    where	dhr_cd_cliente = 1024706007 --Somente HAWK
		    and dhr_dt_data between @data_inicial and @data_final
            --and dhr_vl_quilometros_percorridos > 0
    group	by dhr_cd_cliente
	    ,	dhr_dt_data
	    ,	dhr_nr_rota
	    ,	dhr_vl_quilometros_percorridos

    CREATE NONCLUSTERED INDEX IDX_TabelaContingencia ON #ContigenciaKM (Rota,DataRef);

    -- Materializa KmColetadoFin uma vez por periodo (evita join com view PBI dentro do SQL dinamico)
    drop table if exists #KmColetadoFin;
    select
        aud.IdRota,
        aud.IdTransportadora,
        aud.DataReferencia,
        aud.KmColetadoFin,
        aud.TipoKmColetado
    into #KmColetadoFin
    from dbo.vw_pbi_auditoria_km_rotas as aud with (nolock)
    where aud.IdTransportadora = @IdTransportadora
      and aud.DataReferencia between @data_inicial and @data_final;

    create nonclustered index IX_KmColetadoFin
        on #KmColetadoFin (IdRota, IdTransportadora, DataReferencia);

    -- Motoristas do periodo (evita scan de tb_ml_rotas inteira dentro do SQL dinamico)
    drop table if exists #MotoristasUsu;
    select
        b.Nome,
        b.CPF,
        b.IdMotorista,
        b.IdTransportadora,
        b.DataCriacao,
        usu.usr_cd_usuario,
        row_number() over (partition by b.CPF, b.IdTransportadora order by b.DataCriacao desc) as MaisRecente
    into #MotoristasUsu
    from tb_ml_motoristas as b with (nolock)
    inner join (
        select
            id.DriverId,
            id.IdTransportadora,
            id.Data,
            row_number() over (partition by mot.CPF, mot.IdTransportadora order by id.Data desc) as MaisRecente
        from tb_ml_motoristas as mot with (nolock)
        inner join (
            select
                rt.DriverId,
                rt.IdTransportadora,
                max(rt.DataReferencia) as Data
            from tb_ml_rotas as rt with (nolock)
            where rt.DataReferencia between @data_inicial and @data_final
              and rt.IdTransportadora = @IdTransportadora
            group by rt.DriverId, rt.IdTransportadora
        ) as id
            on mot.IdMotorista = id.DriverId
           and mot.IdTransportadora = id.IdTransportadora
        where mot.CPF <> ''
    ) as r
        on b.IdMotorista = r.DriverId
       and b.IdTransportadora = r.IdTransportadora
       and r.MaisRecente = 1
    left join tb_usuario as usu with (nolock)
        on b.IdMotorista = usu.usr_cd_driverid
       and usu.usr_in_ativo = 1
       and usu.cli_cd_codigo_cliente = @clienteid
    where b.Ativo = 1
      and b.IdTransportadora = @IdTransportadora
      and b.CPF <> '';

    create nonclustered index IX_MotoristasUsu
        on #MotoristasUsu (CPF, IdTransportadora, MaisRecente);

    DECLARE @sql NVARCHAR(MAX);

    --precisa revisar a consulta pois esta duplicando
    SET @sql = '
        SELECT distinct
        a.idtransportadora, ' + CAST(@CodPeriodoPagamento AS VARCHAR) + ' as ppr_cd_periodo,
        --case when b.edit_ambulancia is not null then b.edit_ambulancia else case when  ' + CAST(@Ambulancia AS VARCHAR) + ' = ''1'' then case when AmbulanciaPagamento = ''Sim'' then 1 else 0 end when KmCiclo = ''AMBULANCE'' then 1 else Ambulancia end end AS ppr_in_ambulancia,
        
        isnull(
            b.edit_ambulancia, 
            case ''' + @ParamOrigemAmbulancia + '''
                when ''Silos'' then a.Ambulancia
                when ''Pre Fatura'' then case when pre.KmCiclo = ''AMBULANCE'' then 1 else 0 end
                when ''Looker'' then case when a.AmbulanciaStatus is not null then 1 else 0 end
                else case when pre.KmCiclo = ''AMBULANCE'' then 1 else a.Ambulancia end

            end) ppr_in_ambulancia,

        case 
            when ''' + @ParamOrigemAmbulancia + ''' = ''Looker'' and a.AmbulanciaStatus is not null 
            then 
				case when a.AmbulanciaPagamento = ''Sim'' then 1 else 0 end 
			end ppr_in_ambulancia_aprovada,

        a.dataReferencia as ppr_data_referencia,
        --Será incluido uma parametrização para a Decargo considerar apenas o ServiceCenter
        a.origemsaida as origemsaida,
        coalesce(b.edit_Service_Center,veiculo.vei_ds_base_espelho,case when a.[ServiceCenter] <> a.OrigemSaida and left(a.OrigemSaida,1) in (''E'',''M'') and ' + CAST(@UtilizaSVC AS VARCHAR) + ' <> ''1'' then a.OrigemSaida else a.ServiceCenter end) as serviceCenter,
        isnull(edit_cidade ,a.CidadeDistante) [CidadeBase],
        isnull(edit_Ciclo_PM,a.ciclo) as Ciclo_Pm,
        isnull(b.edit_Placa, a.Placa) as Placa,
        isnull(b.edit_Tipo_Veiculo, case when ' +  @Veiculo + ' is null then a.tipoveiculo else ' +  @Veiculo + ' end) as TipoVeiculo,
        isnull(usu.Nome,a.NomeMotorista) Nome,
        a.UsuarioDA,
        isnull(usu.IdMotorista,a.DriverId) IdMotorista,
        isnull(usu.usr_cd_usuario,a.UsuarioDA) usr_cd_usuario,
        isnull(b.edit_usou_app, a.UsouAPP) as UsouAPP,
        a.idRota,
        a.TIPO,
        isnull(b.edit_quantidade_pacotes_entregues, a.PacotesEntregues) as PacotesEntregues,
        isnull(b.edit_Quantidade_Pacotes, a.TotalPacotes) as TotalPacotes,
        a.PacotesNaoEntregue,
        a.PacotesPendentes,
        0 as QuantidadeFaixa,
        a.TipoRota,
		coalesce(b.edit_Total_KM,b.edit_km_selecionado,audKm.KmColetadoFin, cast(EditFicha.[vmp_kmpagamento] as decimal(10,4)), Cont.KmContingencia) AS KmColetado,
        EnderecosVisitados,
        isnull(feriado.Feriado, 0) as ppr_in_fer,
        case when Domingo.NumDiaSemana = 1 then 1 else 0 end as ppr_in_dom,
        case when isnull(feriado.Feriado, 0) = 1 or Domingo.NumDiaSemana = 1 then 1 else 0 end ppr_in_dom_fer,
        case when Domingo.NumDiaSemana = 7 then 1 else 0 end as ppr_in_sab,
        isnull(b.edit_Quantidade_Pontos, a.QuantidadePontos) as QuantidadePontos,
        isnull(b.edit_Quantidade_Paradas, case when ''' + @fontedados + ''' = ''Pre Fatura'' then isnull(pre.Parada,a.QuantidadeParadas) else a.QuantidadeParadas end) QuantidadeParadas,
        EnderecosNaoVisitados,
        case when b.edit_zerar_pagamento = 1 then 1 else 0 end ppr_in_zerar_rota,
        case when coalesce(b.edit_Total_KM,b.edit_km_selecionado) is null then audKm.TipoKmColetado else ''Km Editado'' end TipoKmColetado

    FROM vw_ml_rotas as a (nolock)
    LEFT JOIN (select * from #tb_pgto_periodo_rota_edit (nolock) ) as b
        ON cast(a.idRota as varchar) = b.edit_rota
    left join (
        select
            cli_id_logistics,a.*
        from tb_veiculos as a (NOLOCK)
        inner join tb_clientes as b (NOLOCK)
            on a.vei_cd_cliente = b.cli_cd_codigo_cliente
    ) as veiculo
        on a.idtransportadora = veiculo.cli_id_logistics
        and a.Placa = veiculo.vei_ds_placa
    left join vw_prefatura_espelhos as pre
        on a.idRota = pre.idRota
        and a.idtransportadora = pre.idtransportadora
    left join tb_validacao_mapas as EditFicha
        on a.idRota = EditFicha.vmp_cd_rota
    left join tb_fin_base_km_trevo as  trevo
        on a.idtrevo = trevo.bkt_cd_base_km_trevo
    left join vw_feriados as feriado
        on a.dataReferencia = feriado.Data
        and a.IdTransportadora = feriado.idtransportadora
    left join dimdata as Domingo
        on cast(a.datahorainicio as date) = Domingo.data


    left  join tb_ml_motoristas as ml on a.DriverId = ml.IdMotorista and a.idtransportadora = ml.IdTransportadora and ml.Ativo = 1
    left  join #MotoristasUsu as usu
        on ml.CPF = usu.CPF
       and ml.IdTransportadora = usu.IdTransportadora
       and usu.MaisRecente = 1

    left join tb_motorista as mot
        on isnull(usu.usr_cd_usuario,a.UsuarioDA) = mot.mot_cd_usuario

    left join #KmColetadoFin as audKm
        on a.IdRota = audKm.IdRota
       and a.IdTransportadora = audKm.IdTransportadora
       and a.DataReferencia = audKm.DataReferencia

    left join #ContigenciaKM as Cont
        on a.IdRota = Cont.Rota
         and a.IdTransportadora = Cont.Cliente

    where a.datareferencia between ''' + CONVERT(VARCHAR(10), @data_inicial, 120) + ''' and ''' + CONVERT(VARCHAR(10), @data_final, 120) + '''
        and a.idtransportadora = ' + CONVERT(VARCHAR(10), @IdTransportadora) + '
        --and excluido = 0
        and a.TotalPacotes > 0
        --and StatusRota <> ''planned''
        --and isnull(SubStatusRota, '''') <> ''cancelled''
        and (mot_ctn_cd_tipo_contrato = ' + CONVERT(VARCHAR(10), @tipocontrato)  + ' or ' + CONVERT(VARCHAR(10), @tipocontrato)  + ' = ''-1'')
        and not exists (select 
                            1 
                          from 
                            tb_veiculos v with(nolock)
                            join tb_clientes c with(nolock) on v.vei_cd_cliente = c.cli_cd_codigo_cliente
                        where
                            v.vei_in_ativo = 1
                            and v.vei_in_excluido = 0
                            and v.vei_zerar_espelho = 1
                            and a.IdTransportadora = c.cli_id_logistics
                            and a.Placa = v.vei_ds_placa
                        )
        
        and (a.IdRota = ''' + cast(@IdRota as varchar(15))+ ''' or ''' + cast(@IdRota as varchar(15)) + ''' = ''-1'')
		and (
				exists (select 
							1 
						from 
							tb_pgto_periodo_rota pgto with(nolock)
						where 
							pgto.ppr_cd_motorista_nfs = ''' + cast(@CodEspelho as varchar(15)) + ''' 
							and pgto.ppr_cd_tipo_pgto = 1362
							and pgto.ppr_in_excluido = 0
							and pgto.ppr_cd_rota = a.IdRota
						)
				or
				''' + cast(@CodEspelho as varchar(15)) + ''' = ''-1''
			)
        ';



    drop table if exists #tabela;
    create table #tabela
    (
        idtransportadora int,
        ppr_cd_periodo varchar(10),
        ppr_in_ambulancia int,
        ppr_in_ambulancia_aprovada int,
        ppr_data_referencia date,
        origemsaida varchar(20),
        servicecenter varchar(20),
        CidadeBase varchar(100),
        Ciclo_Pm varchar(10),
        Placa varchar(20),
        TipoVeiculo varchar(50),
        NomeMotorista varchar(250),
        UsuarioDA int,
        DriverId int,
        usr_cd_usuario int,
        UsouAPP varchar(10),
        idRota varchar(50),
        Tipo varchar(50),
        PacotesEntregues int,
        TotalPacotes int,
        PacotesNaoEntregue int,
        PacotesPendentes int,
        QuantidadeFaixa int,
        TipoRota varchar(50),
        KmColetado decimal(10,2),
        EnderecosVisitados int,
        ppr_in_fer bit,
        ppr_in_dom bit,
        ppr_in_dom_fer bit,
        ppr_in_sab bit,
        QuantidadePontos int,	
        QuantidadeParadas int,
        EnderecosNaoVisitados int,
        ppr_in_zerar_rota bit,
        TipoKmColetado varchar(100)
        --QtdRota int
    );


    --select @sql

     print '#tabela'

    insert into #tabela
    exec sp_executesql @sql;

	
	--Adicionado por Saulo Barros em 13/03/2026
	--Caso estam rotas do mesmo DriverId, em que algumas rotas estão com usuarioda e outras não, atualiza as que não tiverem usuário DA
	update
		t
	set
		t.UsuarioDA = t2.UsuarioDA
	from
		#tabela t
		join (
			select
				DriverId
				,max(UsuarioDA) UsuarioDA
			from
				#tabela
			where
				UsuarioDA is not null
				and DriverId is not null
			group by
				DriverId
		) t2 on t.DriverId = t2.DriverId
	where
		t.UsuarioDA is null
		and t.DriverId is not null


	--Adicionado por Saulo Barros em 24/03/2026
	--caso já tenha sido gerado um espelho para motorista em um driverid 
	--e tenha rotas deste mesmo motorista com outro driverid, considera o driverid que foi criado o espelho
	update
		t
	set
		t.DriverId = e.mtn_driver_id
	from
		#tabela t
		join tb_ml_motoristas m with(nolock) on t.DriverId = m.IdMotorista
											and t.IdTransportadora = m.IdTransportadora
		join (
			select
				m.CPF
				,e.mtn_driver_id
			from
				tb_pag_espelhos e with(Nolock)
				join tb_clientes c with(nolock) on e.mtn_cod_cliente = c.cli_cd_codigo_cliente
				join tb_ml_motoristas m with(nolock) on e.mtn_driver_id = m.IdMotorista
													and c.cli_id_logistics = m.IdTransportadora
			where
				e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
				and mtn_in_excluido = 0
                and m.CPF <> ''
		) e on m.CPF = e.CPF and t.DriverId <> e.mtn_driver_id
	

    alter table #tabela
    add svc_espelho varchar(100) null;


         print 'update'

    update a
    set svc_espelho = case
        when a.idtransportadora = @IdTransportadora and @DivisaoEspelho = 'true' then a.servicecenter
        else b.servicecenter
    end
    from #tabela as a
        left join (
        select
            DriverId,
            case when @UtilizaSVC = 1 then servicecenter else case when origemsaida is not null then origemsaida else servicecenter end end as servicecenter, --repassar esta regra com o saulo pois ja existe uma tratativa ba coluna na no insert da tabela tb_ml_rotas
            row_number() over(partition by DriverId order by count(*) desc) as ordem
        from #tabela
        group by DriverId, case when @UtilizaSVC = 1 then servicecenter else case when origemsaida is not null then origemsaida else servicecenter end end
    ) as b
        on a.DriverId = b.DriverId
    where b.ordem = 1;




    --- BASES QUE USA O XPT (ORIGEMSAIDA) PARA CRIAR O ESPELHO
    update  a
    set     svc_espelho = origemsaida
    from    #tabela as a
    inner   join tb_bases as b on a.origemsaida = b.bss_ds_sigla and b.bss_cd_idtransportadora = @IdTransportadora
    where   bss_espelho_xpt = 1


if @clienteid = 66
begin


    --Regra HARDCODE na v2, paliativo
    --Será analisado como vamos aplicar na v3
    update  a
    set     KmColetado = KmTotal
        ,   TipoKmColetado = 'Km coletado do Silos'
    from    #tabela as a
    join    tb_ml_rotas as b with(nolock) 
            on a.IdRota = b.IdRota
            and b.IdTransportadora = 1024706007
            and b.DataReferencia between  @data_inicial and @data_final
    where   a.servicecenter = 'SSP16'
            and (a.TipoVeiculo like 'Utilitário Localiza 202%'
                or a.TipoVeiculo = 'Utilitários SDD')
            and KmTotal is not null


    update  a
    set     KmColetado = pontosRotasPacotesKm
        ,   TipoKmColetado = 'KM latitude e longetude dos Pacotes'
    from    #tabela as a
    join    tb_ml_processamento_km_rotas as b with(nolock) 
            on a.IdRota = b.IdRota
    where   a.svc_espelho in ('SMG9','EMG30','ERJ7','EES7','SMG2','SMG10','ERJ1',
                              'ERJ5','SRJ12','SMG11','SRJ5','EDF12 ','SGO3','EGO2','EMG31','SMR1','SRJ3','SRJ9',
                              'SES1')
            and pontosRotasPacotesKm <> 0
            and a.TipoKmColetado not in ('KM do app Irisys','Km Editado')


    update  a
    set     TipoVeiculo = 'Utilitários'
    from    #tabela as a
    where   svc_espelho = 'SES1'
        and Placa in (
                                'SDD-ODK7A08'
                                ,'SDD-QUS7G24'
                                ,'SDD-RGB0H33'
                                ,'SDD-MTXSA40'
                            )    
                            

    update  a
    set     KmColetado = 1
        ,   TipoKmColetado = 'Km não coletado. Aplicado Km mínimo.'
    from    #tabela as a
    where   KmColetado = 0

                            
end            


     print '4 VALIDAÇÃO E ERRO DE ESPELHO (MOTORISTA)'

-- 4 VALIDAÇÃO E ERRO DE ESPELHO (MOTORISTA)
    --Motorista obrigatório
    --Base obrigatória
    --Tipo de contrato obrigatório
    --Motorista inexistente na tb_motorista
    --Base inexistente na tb_bases

INSERT INTO dbo.tb_pag_espelhos_erros
(
    pee_cd_motorista,
    pee_nm_motorista,
    pee_base,
    pee_cd_periodo,
    pee_ds_erro,
    pee_dh_criacao
)
SELECT DISTINCT
    a.UsuarioDA,
    a.NomeMotorista,
    a.svc_espelho,
    @CodPeriodoPagamento,
    CASE
        WHEN a.UsuarioDA IS NULL THEN 'Motorista não informado'
        WHEN mot.mot_cd_usuario IS NULL THEN 'Motorista não cadastrado'
        WHEN a.svc_espelho IS NULL THEN 'Base (SVC) não definida'
        --WHEN bss.bss_cd_base IS NULL THEN 'Base (SVC) não cadastrada'
        WHEN mot.mot_ctn_cd_tipo_contrato IS NULL THEN 'Tipo de contrato não informado'
       -- ELSE 'Erro não classificado no espelho'
    END,
    @agora
FROM #tabela a
LEFT JOIN tb_motorista mot
    ON a.UsuarioDA = mot.mot_cd_usuario
LEFT JOIN tb_bases bss
    ON a.svc_espelho = bss.bss_ds_sigla
   AND mot_cd_cliente = bss_cod_cliente
WHERE
    a.UsuarioDA IS NULL
 OR mot.mot_cd_usuario IS NULL
 OR a.svc_espelho IS NULL
 --OR bss.bss_cd_base IS NULL
 OR mot.mot_ctn_cd_tipo_contrato IS NULL;

     print '6 Remoção dos registros inválidos da base temporária'

-- 6 Remoção dos registros inválidos da base temporária
DELETE a
FROM #tabela a
LEFT JOIN tb_motorista mot
    ON a.UsuarioDA = mot.mot_cd_usuario
LEFT JOIN tb_bases bss
    ON a.svc_espelho = bss.bss_ds_sigla
   AND a.idtransportadora = bss.bss_cd_idtransportadora
WHERE
 --   a.UsuarioDA IS NULL
 --OR mot.mot_cd_usuario IS NULL
  a.svc_espelho IS NULL
 --OR bss.bss_cd_base IS NULL;
 --OR mot.mot_ctn_cd_tipo_contrato IS NULL

      print '#espelho'


    -- /*consolida os motoristas para gerar o codigo dos espelhos*/
    drop table if exists #espelho;
    select
        distinct
        ROW_NUMBER() OVER(PARTITION BY NomeMotorista ORDER BY DriveriD DESC) valid,
        UsuarioDA as mtn_cd_motorista,
        DriverId mtn_driver_id,
        NomeMotorista as mtn_nome_motorista,
        @CodPeriodoPagamento as mtn_cd_pgto_periodo,
        228 mtn_cd_status, -- 228 e o status de Em Apuracao
        0 as mtn_vl_nfs,
        null mtn_ds_link_nfs,
        dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao, --precisa ser um parametro na pgto_periodo_rota
        @agora mtn_dh_criacao,
        @cd_usr mtn_cd_usr_criacao,
        @agora mtn_dh_modificacao,
        @cd_usr mtn_cd_usr_modificacao,
        isnull(espelho.mtn_in_excluido,0) as mtn_in_excluido,
        periodo.pgp_cd_cliente as mtn_cod_cliente,
        count(*) as mtn_qt_rotas,
        94  as mtn_cd_tipo_espelho, -- preciso entender que codigo e este
        @IdCliTransportadora as mtn_cd_cliente_transportadora,
        bss_cd_base as mtn_cd_base,
        svc_espelho as mtn_base_principal,
        mot.mot_ctn_cd_tipo_contrato as mtn_cd_tipo_contrato, -- precisa criar regra, se o tipo de contrato mudar, precisa excluir o antigo e inserir o novo.
        @DataPrevistaPagamento mtn_dt_prevista_pagamento
    into #espelho
    from #tabela as a
        left join [tb_pgto_periodo] as periodo (NOLOCK)
        on @CodPeriodoPagamento = periodo.pgp_cd_periodo
        left join tb_clientes (NOLOCK) AS CLI
        ON CLI.cli_cd_codigo_cliente = periodo.pgp_cd_cliente
        left join tb_bases as c (NOLOCK)
        on a.svc_espelho = c.bss_ds_sigla
        and a.idtransportadora = c.bss_cd_idtransportadora
        left join tb_motorista as mot
        on UsuarioDA = mot.mot_cd_usuario
        left join tb_pag_espelhos as espelho 
        on UPPER(NomeMotorista) = UPPER(espelho.mtn_nome_motorista)
           and ppr_cd_periodo = espelho.mtn_cd_pgto_periodo
           --and svc_espelho = espelho.mtn_base_principal
    WHERE pgp_cd_status = 1 -- se e pgp_in_excluido ou pgp_cd_status
    and isnull(espelho.mtn_in_excluido,0) = 0
    GROUP BY
    DriveriD,
    UsuarioDA,
    NomeMotorista,
    bss_cd_base,
    svc_espelho,
    periodo.pgp_cd_cliente,
    mot.mot_ctn_cd_tipo_contrato,
    espelho.mtn_in_excluido
;

      print '1 ELIMINA DUPLICIDADE ESPELHO'
-- 1 ELIMINA DUPLICIDADE ESPELHO
DROP TABLE IF EXISTS #cte;

SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY 
        mtn_nome_motorista, 
        mtn_cd_pgto_periodo, 
        mtn_cd_motorista, 
        mtn_base_principal 
        --mtn_cd_operacao 
        ORDER BY mtn_qt_rotas DESC, mtn_dh_criacao DESC
    ) AS rn
INTO #cte
FROM #espelho;

      print '2 INSERÇÃO DOS ERROS DE ESPELHO'

-- 2 INSERÇÃO DOS ERROS DE ESPELHO
--Espelho duplicado no contexto do período
INSERT INTO dbo.tb_pag_espelhos_erros (
    pee_cd_motorista,
    pee_nm_motorista,
    pee_base,
    pee_cd_periodo,
    pee_ds_erro,
    pee_dh_criacao
)
SELECT
        mtn_cd_motorista, 
        mtn_nome_motorista, 
        mtn_base_principal, 
        mtn_cd_pgto_periodo, 
       'Espelho duplicado',
        @agora
FROM #cte
WHERE rn > 1;


      print '5 Atualiza para exluido na [tb_pag_espelhos] caso o espelho já exista'

-- 5 Atualiza para exluido na [tb_pag_espelhos] caso o espelho já exista

UPDATE e
SET e.mtn_in_excluido = 1
FROM tb_pag_espelhos  e
WHERE EXISTS (
    SELECT 1
    FROM tb_pag_espelhos_erros a
    WHERE a.pee_cd_motorista = e.mtn_cd_motorista -- 1897261
      and a.pee_base = e.mtn_base_principal -- EES6
      and a.pee_dh_criacao = @agora
      and a.pee_cd_periodo = @CodPeriodoPagamento
      and a.pee_ds_erro = 'Espelho duplicado'
);

      print '3 DELETA DUPLICIDADE ESPELHO'

-- 3 DELETA DUPLICIDADE ESPELHO
DELETE t
FROM #espelho t
JOIN #cte c
    ON 
       c.mtn_cd_motorista = t.mtn_cd_motorista
   and UPPER(c.mtn_nome_motorista) = UPPER(t.mtn_nome_motorista)
   and c.mtn_base_principal = t.mtn_base_principal
   and c.mtn_cd_pgto_periodo = t.mtn_cd_pgto_periodo
   --and c.mtn_cd_operacao = t.mtn_cd_operacao
WHERE c.rn > 1;

      print '1 ELIMINA DUPLICIDADE ROTA'

-- 1 ELIMINA DUPLICIDADE ROTA
DROP TABLE IF EXISTS #ctr;

SELECT
    *,
    ROW_NUMBER() OVER (
        PARTITION BY idRota
        ORDER BY KmColetado DESC, ppr_data_referencia DESC
    ) AS rn
INTO #ctr
FROM #tabela;

      print '2 INSERÇÃO DOS ERROS DE ROTA'

-- 2 INSERÇÃO DOS ERROS DE ROTA
--Rota duplicada no contexto do período
INSERT INTO dbo.tb_pgto_periodo_rota_erro (
    pre_cd_rota,
    pre_base,
    pre_cd_periodo,
    pre_ds_erro,
    pre_dh_criacao
)
SELECT
    idRota,
    svc_espelho,
    @CodPeriodoPagamento,
    'Rota duplicada',
    @agora
FROM #ctr
WHERE rn > 1;

      print '3 DELETA DUPLICIDADE ROTA'

-- 3 DELETA DUPLICIDADE ROTA
DELETE t
FROM #tabela t
JOIN #ctr c
    ON t.idRota = c.idRota
WHERE c.rn > 1;

      print '4 INSERÇÃO DOS ERROS DE ROTA'
-- 4 INSERÇÃO DOS ERROS DE ROTA
--Rota sem espelho correspondente
--KM nulo ou inválido
--Quantidade de pacotes negativa
--Rota duplicada no contexto do período
--Base inconsistente com o espelho
INSERT INTO dbo.tb_pgto_periodo_rota_erro
(
    pre_cd_rota,
    pre_base,
    pre_cd_periodo,
    pre_ds_erro,
    pre_dh_criacao
)
SELECT
    a.idRota,
    a.svc_espelho,
    @CodPeriodoPagamento,
    CASE
    --    WHEN a.KmColetado IS NULL OR a.KmColetado <= 0 OR a.KmColetado >= 500 THEN 'KM inválido'
        WHEN b.mtn_cd_motorista IS NULL THEN concat('Usuario não cadastrado no sistema - ', a.NomeMotorista)
    --    ELSE 'Erro não classificado na rota'
    END,
    @agora
FROM #tabela a
LEFT JOIN #espelho b
    ON UPPER(a.NomeMotorista) = UPPER(b.mtn_nome_motorista)
   AND a.svc_espelho = b.mtn_base_principal
   AND b.mtn_cd_pgto_periodo = @CodPeriodoPagamento
   AND b.mtn_in_excluido = 0
WHERE
 --   a.KmColetado IS NULL
 --OR a.KmColetado <= 0
 --OR a.KmColetado >= 500
  b.mtn_cd_motorista IS NULL;

        print '5 Atualiza para exluido na [tb_pgto_periodo_rota] caso a rota já exista'

        print '6 Remoção das rotas inválidas'

---- 6 Remoção das rotas inválidas
--DELETE a
--FROM #tabela a
--LEFT JOIN #espelho b
--    ON UPPER(a.NomeMotorista) = UPPER(b.mtn_nome_motorista)
--   AND a.svc_espelho = b.mtn_base_principal
--   AND b.mtn_cd_pgto_periodo = @CodPeriodoPagamento
--   AND b.mtn_in_excluido = 0
--WHERE
-- --   a.KmColetado IS NULL
-- --OR a.KmColetado <= 0
-- -- OR a.KmColetado >= 500
--  b.mtn_cd_motorista IS NULL;

        print 'MERGE tb_pag_espelhos'

    -- esta etapa insere ou atualiza os dados na tabela de espelhos de pagamento
    MERGE tb_pag_espelhos AS target
    USING (
    
    SELECT
        --Valid,
        ESP.mtn_cd_motorista,
        ESP.mtn_driver_id,
        ESP.mtn_nome_motorista,
        ESP.mtn_cd_pgto_periodo,
        ESP.mtn_cd_status,
        ESP.mtn_vl_nfs,
        ESP.mtn_ds_link_nfs,
        ESP.mtn_dt_prazo_contestacao,
        ESP.mtn_dh_criacao,
        ESP.mtn_cd_usr_criacao,
        ESP.mtn_dh_modificacao,
        ESP.mtn_cd_usr_modificacao,
        ESP.mtn_in_excluido,
        ESP.mtn_cod_cliente,
        ESP.mtn_qt_rotas,
        ESP.mtn_cd_tipo_espelho,
        ESP.mtn_cd_cliente_transportadora,
        ESP.mtn_cd_base,
        ESP.mtn_base_principal,
        @operacao AS mtn_cd_operacao,
        ESP.mtn_cd_tipo_contrato,
        ESP.mtn_dt_prevista_pagamento

        -- este campo e novo, precisa ser criado na tabela tb_pag_espelhos

        --Inclusao de dados bancarios do motorista
        ,MOT.Banco			as mtn_ds_Banco
        ,MOT.NomeTitular	as mtn_ds_NomeTitular
        ,MOT.CpfTitular		as mtn_ds_CpfTitular
        ,MOT.CnpjTitular	as mtn_ds_CnpjTitular
        ,MOT.Agencia		as mtn_ds_Agencia
        ,MOT.Conta			as mtn_ds_Conta
        ,MOT.TipoConta		as mtn_ds_TipoConta
        ,MOT.TipoChavePix	as mtn_ds_TipoChavePix
        ,MOT.ChavePix		as mtn_ds_ChavePix
        ,MOT.CnpjEmpresa	as mtn_ds_CnpjEmpresa
        ,MOT.RazaoSocial	as mtn_ds_RazaoSocial
        ,MOT.NomeFantasia	as mtn_ds_NomeFantasia

    FROM #espelho as ESP
    left join (
				SELECT	*,
						ROW_NUMBER() OVER(PARTITION BY CodigoUsuario ORDER BY CodigoUsuario ASC)	AS ID
				FROM    vw_dados_motoristas (NOLOCK)
			    
                ) AS MOT ON MOT.CodigoUsuario = ESP.mtn_cd_motorista
						    AND MOT.ID = 1
    --where mtn_cd_motorista is not null


) AS source
ON (
            target.mtn_driver_id = source.mtn_driver_id
        --AND target.mtn_base_principal = source.mtn_base_principal
        AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
        AND target.mtn_in_excluido = source.mtn_in_excluido
        and target.mtn_cd_operacao = source.mtn_cd_operacao
        and target.mtn_cd_pgto_periodo = @CodPeriodoPagamento

		and (
				(@DivisaoEspelho = 'true' and target.mtn_base_principal = source.mtn_base_principal)
				or
				@DivisaoEspelho <> 'true'
			)
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
        mtn_cd_tipo_contrato = source.mtn_cd_tipo_contrato,
        mtn_driver_id = source.mtn_driver_id,
        mtn_in_excluido = source.mtn_in_excluido,
		mtn_cd_motorista = isnull(source.mtn_cd_motorista,target.mtn_cd_motorista),

         --ajuste para atualizar somente quando a data não for atualizada manualmente
        mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end


WHEN NOT MATCHED THEN
    INSERT (
        mtn_cd_motorista,
        mtn_driver_id,
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
        mtn_cd_tipo_contrato,
        
        mtn_ds_Banco,
        mtn_ds_NomeTitular,
        mtn_ds_CpfTitular,
        mtn_ds_CnpjTitular,
        mtn_ds_Agencia,
        mtn_ds_Conta,
        mtn_ds_TipoConta,
        mtn_ds_TipoChavePix,
        mtn_ds_ChavePix,
        mtn_ds_CnpjEmpresa,
        mtn_ds_RazaoSocial,
        mtn_ds_NomeFantasia,
        mtn_dt_prevista_pagamento

    )
    VALUES (
        source.mtn_cd_motorista,
        source.mtn_driver_id,
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
        source.mtn_cd_tipo_contrato,
        source.mtn_ds_Banco,
        source.mtn_ds_NomeTitular,
        source.mtn_ds_CpfTitular,
        source.mtn_ds_CnpjTitular,
        source.mtn_ds_Agencia,
        source.mtn_ds_Conta,
        source.mtn_ds_TipoConta,
        source.mtn_ds_TipoChavePix,
        source.mtn_ds_ChavePix,
        source.mtn_ds_CnpjEmpresa,
        source.mtn_ds_RazaoSocial,
        source.mtn_ds_NomeFantasia,
        source.mtn_dt_prevista_pagamento
        
    );

    --alter table [tb_pgto_periodo_rota] add ppr_qtd_rota int

            print 'MERGE tb_pgto_periodo_rota'

    --esta etapa insere ou atualiza os dados na tabela de pagamento de periodo de rota
    MERGE INTO tb_pgto_periodo_rota AS target
USING (
    SELECT 
        ppr_cd_periodo,
        idrota as ppr_cd_rota,
        null as ppr_cd_faixa_km, --esta coluna precisa sere preenchida na procedure de calculo pois depende da faixa de km da transportadora.
        placa as ppr_ds_placa,
        TipoVeiculo as ppr_ds_tipo_veiculo,
        Ciclo_Pm as ppr_ds_ciclo,
        TotalPacotes as ppr_qt_pacotes,
        -- QuantidadePontos as ppr_qt_pontos,
        QuantidadeFaixa as ppr_qt_faixa, --nao existe pagamento de pontos e paradas ao mesmo tempo. inclui como parametro o pagament se para ou ponto. tempos que utilizar uma unica coluna
        0 as ppr_in_area_risco, --infromacao que vira da ficha de rota
        0 as ppr_in_ajudante, --infromacao que vira da ficha de rota
        ppr_in_fer, --precisa avisar o saulo para se orientar quando fizer os calculos
        ppr_in_dom, --precisa avisar o saulo para se orientar quando fizer os calculos
        ppr_in_dom_fer,
        ppr_in_sab,
        ppr_in_ambulancia,
        ppr_in_ambulancia_aprovada,
        @agora as ppr_dh_criacao,
        @cd_usr as ppr_cd_usr_criacao,
        @agora as ppr_dh_modificacao,
        @cd_usr as ppr_cd_usr_modificacao,
        1 as ppr_in_ativo,
        0 as ppr_in_excluido,
        UsuarioDA as ppr_cd_motorista,
        PacotesEntregues as ppr_qt_pacotes_entregues,
        PacotesPendentes as ppr_qt_pacotes_pendentes,
        b.mtn_cd_motorista_nfs as ppr_cd_motorista_nfs,
        b.mtn_cd_motorista_nfs as ppr_cd_pgto_espelho,
        UsouApp as ppr_usou_app,
        ppr_data_referencia,
        b.mtn_base_principal as ppr_base_principal,
        TipoRota as ppr_tipo_rota,
        NomeMotorista as ppr_nome_motorista,
        CidadeBase as ppr_nm_cidade,
        'LM' as ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        'Rota Mercado Livre' as ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento (este tambem e novo, precisa ser criado na tb_pgto_periodo_rota)
        a.KmColetado as ppr_total_km,
        EnderecosVisitados as ppr_qtd_enderecos_visitados,
        QuantidadePontos  ppr_qt_pontos ,
        QuantidadeParadas ppr_qt_paradas,
        isnull(PacotesNaoEntregue,0) ppr_vl_insucessos,
        isnull(EnderecosNaoVisitados,0) ppr_qt_enderecos_nao_visitados,
        nullif(PacotesEntregues,0) / nullif(cast(TotalPacotes as decimal(10,2)),0) as ppr_vl_success_delivery,
        1362 as ppr_cd_tipo_pgto,
        DriverId as ppr_driver_id,
        a.ppr_in_zerar_rota,
        a.TipoKmColetado as ppr_nm_origem_km

    -- precisa criar esta coluna na tabela tb_pgto_periodo_rota e entender como ia funcionar este calculo com o saulo

    FROM #tabela AS a
        INNER JOIN tb_pag_espelhos AS b (NOLOCK)
        ON a.DriverId = b.mtn_driver_id
            AND (a.svc_espelho = b.mtn_base_principal)
            and ppr_cd_periodo = b.mtn_cd_pgto_periodo
            AND b.mtn_cd_status IN (34,228,38)
            and b.mtn_in_excluido = 0
    --where mtn_cd_motorista is not NULL
) AS source
ON (
    target.ppr_cd_periodo = source.ppr_cd_periodo
        AND target.ppr_cd_rota = source.ppr_cd_rota
        and target.ppr_cd_periodo = @CodPeriodoPagamento
        and target.ppr_driver_id = source.ppr_driver_id
        and target.ppr_in_excluido = 0
        
        --and target.ppr_cd_motorista = source.ppr_cd_motorista
)
WHEN MATCHED THEN
    UPDATE SET
        ppr_ds_placa = source.ppr_ds_placa,
        ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
        ppr_ds_ciclo = source.ppr_ds_ciclo,
        ppr_qt_faixa = source.ppr_qt_faixa,
        ppr_in_area_risco = source.ppr_in_area_risco,
        ppr_in_ajudante = source.ppr_in_ajudante,
        ppr_in_fer = source.ppr_in_fer,
        ppr_in_dom = source.ppr_in_dom,
        ppr_in_dom_fer = source.ppr_in_dom_fer,
        ppr_dh_modificacao = @agora, -- preciso criar um parametro para a data de modificacao
        ppr_cd_usr_modificacao = @cd_usr, -- preciso criar um parametro para o usuario que esta executando o processo
        ppr_cd_motorista = source.ppr_cd_motorista,
        ppr_qt_pacotes_entregues = source.ppr_qt_pacotes_entregues,
        ppr_qt_pacotes_pendentes = source.ppr_qt_pacotes_pendentes,
        ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
        ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
        ppr_usou_app = source.ppr_usou_app,
        ppr_data_referencia = source.ppr_data_referencia,
        ppr_base_principal = source.ppr_base_principal,
        ppr_tipo_rota = source.ppr_tipo_rota,
        ppr_nome_motorista = source.ppr_nome_motorista,
        ppr_nm_cidade = source.ppr_nm_cidade,
        ppr_total_km = source.ppr_total_km,
        ppr_qtd_enderecos_visitados = source.ppr_qtd_enderecos_visitados,
        ppr_qt_pontos  = source. ppr_qt_pontos,
        ppr_qt_paradas  = source.ppr_qt_paradas,
        ppr_in_sab = source.ppr_in_sab,
        ppr_qt_enderecos_nao_visitados = source.ppr_qt_enderecos_nao_visitados,
        ppr_vl_success_delivery = source.ppr_vl_success_delivery,
        ppr_in_ambulancia = source.ppr_in_ambulancia,
        ppr_in_ambulancia_aprovada = source.ppr_in_ambulancia_aprovada,
        ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
        ppr_vl_insucessos = source.ppr_vl_insucessos,
        ppr_driver_id = source.ppr_driver_id,
		ppr_nm_pgto = source.ppr_nm_pgto,
		ppr_qt_pacotes = source.ppr_qt_pacotes,
        ppr_in_zerar_rota = source.ppr_in_zerar_rota,
        ppr_nm_origem_km = source.ppr_nm_origem_km

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        ppr_cd_periodo,
        ppr_cd_rota,
        ppr_ds_placa,
        ppr_ds_tipo_veiculo,
        ppr_ds_ciclo,
        ppr_qt_pacotes,
        ppr_qt_faixa,
        ppr_in_area_risco,
        ppr_in_ajudante,
        ppr_in_fer,
        ppr_in_dom,
        ppr_in_dom_fer,
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
        ppr_tipo_rota,
        ppr_nome_motorista,
        ppr_nm_cidade,
        ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
        ppr_total_km,
        ppr_qtd_enderecos_visitados,
        ppr_qt_pontos,
        ppr_qt_paradas,
        ppr_qt_enderecos_nao_visitados,
        ppr_vl_success_delivery,
        ppr_in_ambulancia,
        ppr_in_ambulancia_aprovada,
        ppr_cd_tipo_pgto,
        ppr_vl_insucessos,
        ppr_driver_id,
        ppr_in_zerar_rota,
        ppr_nm_origem_km
    )
    VALUES (
        source.ppr_cd_periodo,
        source.ppr_cd_rota,
        source.ppr_ds_placa,
        source.ppr_ds_tipo_veiculo,
        source.ppr_ds_ciclo,
        source.ppr_qt_pacotes,
        source.ppr_qt_faixa,
        source.ppr_in_area_risco,
        source.ppr_in_ajudante,
        source.ppr_in_fer,
        source.ppr_in_dom,
        source.ppr_in_dom_fer,
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
        source.ppr_tipo_rota,
        source.ppr_nome_motorista,
        source.ppr_nm_cidade,
        source.ppr_cd_tipo, --seria interessante mudar o nome para tipo de operacao
        source.ppr_nm_pgto, --seria interessante mudar o nome para tipo de lancamento
        source.ppr_total_km,
        source.ppr_qtd_enderecos_visitados   ,
        source.ppr_qt_pontos,
        source.ppr_qt_paradas,
        source.ppr_qt_enderecos_nao_visitados,
        source.ppr_vl_success_delivery,
        source.ppr_in_ambulancia,
        source.ppr_in_ambulancia_aprovada,
        source.ppr_cd_tipo_pgto,
        source.ppr_vl_insucessos,
        source.ppr_driver_id,
        source.ppr_in_zerar_rota,
        source.ppr_nm_origem_km
    );


	--Adicionado por Saulo Barros em 25/03/2026 para excluir rotas que entraram no período mas não estão mais na #tabela
    if @idrota is null
    begin
	    update
		    p
	    set
		    p.ppr_in_excluido = 1
	    from
		    tb_pgto_periodo_rota p
		    join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
									    and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
									    and e.mtn_cd_operacao = @Operacao
		    left join #tabela r on p.ppr_cd_rota = r.IdRota
	    where
		    p.ppr_cd_periodo = @CodPeriodoPagamento
		    and p.ppr_in_excluido = 0
		    and p.ppr_cd_tipo_pgto = 1362
		    and e.mtn_cd_status in (34,228,38,1298)
		    and r.IdRota is null
    end


--alter o nome da coluna ppr_enderecos_visitados para ppr_qtd_enderecos_visitados - OK
--cruzamento com a vw_dados_motoristas para trazer os dados bancarios na tabela tb_pag_espelhos, existe ja o cruamento feito na UspFinGeraPagamento --OK
--executar a procedure de pagamento saida e validar os valores de acordo com a tela de cadastro de base frete
GO
