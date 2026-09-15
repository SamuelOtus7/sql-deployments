-- ============================================================
-- BASELINE: dbo.UspGeraAtualizaCidadesDistanteDiaPacote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote]
(
      @datainicio       DATE    = NULL
    , @datafim          DATE    = NULL
    , @IdTransportadora INT     = NULL
)

as

begin

if @datainicio is null begin set @datainicio =  cast(getdate()-5 as date) end
if @datafim   is null begin set @datafim =  cast(getdate() as date) end

--declare @datainicio date = cast(getdate()-5 as date)
--declare @datafim date = cast(getdate() as date)

/*
BEGIN
    ;WITH CTE AS (
        SELECT TOP (500)
            p.Id -- ou outra chave primária da tabela `tb_ml_pacotes`
        FROM tb_ml_pacotes p WITH (NOLOCK)
        LEFT JOIN tb_dra_cidades_geo geo WITH (NOLOCK)
            ON p.LatitudeEnderecoParada = geo.dcg_nr_latitude
            AND p.LongitudeEnderecoParada = geo.dcg_nr_longitude
        WHERE
            p.Excluido = 0
            AND p.DataReferencia BETWEEN @datainicio AND @datafim
            AND p.cidadedistante = 1
            AND geo.dcg_ds_cidade IS NOT NULL
            AND p.Cidade IS NULL
    )
    UPDATE p
    SET Cidade = geo.dcg_ds_cidade
    FROM tb_ml_pacotes p WITH  (ROWLOCK, READPAST, UPDLOCK) 
    INNER JOIN CTE ON p.Id = CTE.Id
    LEFT JOIN tb_dra_cidades_geo geo WITH (NOLOCK)
        ON p.LatitudeEnderecoParada = geo.dcg_nr_latitude
        AND p.LongitudeEnderecoParada = geo.dcg_nr_longitude;

END
*/

--- faz o update do pacote mais distante pra tb_ml_rotas 
/*
update pacotes
set
	   pacotes.cidade = coalesce(regiaoAldeia.Distrito,regiaoDistrito.Distrito,regiaoBairro.Distrito,regiaoSuburbio.Distrito
       ,case when geo.dcg_ds_cidade = 'NOT_FOUND' then dcg_ds_village else geo.dcg_ds_cidade end   ) 

from tb_ml_pacotes as pacotes with(nolock)
	
inner join tb_ml_rotas as rota with(nolock)
on rota.idrota = pacotes.idrota
and rota.idtransportadora = pacotes.idtransportadora 

join tb_dra_cidades_geo as geo with(nolock)
on pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
and pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude

inner join tb_clientes as cli
on cli.cli_id_logistics = pacotes.IdTransportadora

left join vw_fin_definie_cidade_distrito as regiaoAldeia
on cli.cli_cd_codigo_cliente = fcd_cd_cliente
and regiaoAldeia.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoAldeia.Base
and regiaoAldeia.Regiao = 'Aldeia'
and regiaoAldeia.Distrito =  geo.dcg_ds_hamlet

left join vw_fin_definie_cidade_distrito as regiaoDistrito
on cli.cli_cd_codigo_cliente = regiaoDistrito.fcd_cd_cliente
and regiaoDistrito.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoDistrito.Base
and regiaoDistrito.Regiao = 'Distrito'
and regiaoDistrito.Distrito =  geo.dcg_ds_cidade_distrito


left join vw_fin_definie_cidade_distrito as regiaoSuburbio
on cli.cli_cd_codigo_cliente = regiaoSuburbio.fcd_cd_cliente
and regiaoSuburbio.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoSuburbio.Base
and regiaoSuburbio.Regiao = 'Suburbio'
and regiaoSuburbio.Distrito =  geo.dcg_ds_suburbio

left join vw_fin_definie_cidade_distrito as regiaoBairro
on cli.cli_cd_codigo_cliente = regiaoBairro.fcd_cd_cliente
and regiaoBairro.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoBairro.Base
and regiaoBairro.Regiao = 'Bairro'
and regiaoBairro.Distrito =  geo.dcg_ds_bairro


where 1=1
and LatitudeEnderecoParada is not null
and LongitudeEnderecoParada is not null
and PACOTES.datareferencia between @datainicio and @datafim

and rota.StatusRota <> 'planned'
and rota.excluido = 0 
and (pacotes.cidade is null  or pacotes.cidade = 'not_found' 
        or pacotes.cidade = '-' )
and (
        pacotes.IdTransportadora = @IdTransportadora
        or @IdTransportadora is null
     )

/*and rota.idrota =  283996049*/

*/

update pacotes
set
	   pacotes.cidade = coalesce(regiaoPerimetro.Cidade, regiaoAldeia.Distrito,regiaoDistrito.Distrito,regiaoBairro.Distrito,regiaoSuburbio.Distrito
       ,case when geo.dcg_ds_cidade = 'NOT_FOUND' then dcg_ds_village else geo.dcg_ds_cidade end   ) 

from tb_ml_pacotes as pacotes with(nolock)
	
inner join tb_ml_rotas as rota with(nolock)
on rota.idrota = pacotes.idrota
and rota.idtransportadora = pacotes.idtransportadora 

join tb_dra_cidades_geo as geo with(nolock)
on pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
and pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude

inner join tb_clientes as cli
on cli.cli_id_logistics = pacotes.IdTransportadora

outer apply (
    select top 1 r.Cidade
    from tb_cidades_regiao_nao_identificadas_api as r
    where r.IdTransportadora = pacotes.IdTransportadora
      and r.Ativo = 1
      and pacotes.LatitudeEnderecoParada  between r.LatitudeMin  and r.LatitudeMax
      and pacotes.LongitudeEnderecoParada between r.LongitudeMin and r.LongitudeMax
) as regiaoPerimetro

left join vw_fin_definie_cidade_distrito as regiaoAldeia
on cli.cli_cd_codigo_cliente = fcd_cd_cliente
and regiaoAldeia.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoAldeia.Base
and regiaoAldeia.Regiao = 'Aldeia'
and regiaoAldeia.Distrito =  geo.dcg_ds_hamlet

left join vw_fin_definie_cidade_distrito as regiaoDistrito
on cli.cli_cd_codigo_cliente = regiaoDistrito.fcd_cd_cliente
and regiaoDistrito.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoDistrito.Base
and regiaoDistrito.Regiao = 'Distrito'
and regiaoDistrito.Distrito =  geo.dcg_ds_cidade_distrito


left join vw_fin_definie_cidade_distrito as regiaoSuburbio
on cli.cli_cd_codigo_cliente = regiaoSuburbio.fcd_cd_cliente
and regiaoSuburbio.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoSuburbio.Base
and regiaoSuburbio.Regiao = 'Suburbio'
and regiaoSuburbio.Distrito =  geo.dcg_ds_suburbio

left join vw_fin_definie_cidade_distrito as regiaoBairro
on cli.cli_cd_codigo_cliente = regiaoBairro.fcd_cd_cliente
and regiaoBairro.Cidade =  geo.dcg_ds_cidade 
and case when rota.ServiceCenter <> rota.OrigemSaida or rota.OrigemSaida is null
			then OrigemSaida else rota.ServiceCenter end = regiaoBairro.Base
and regiaoBairro.Regiao = 'Bairro'
and regiaoBairro.Distrito =  geo.dcg_ds_bairro


where 1=1
and LatitudeEnderecoParada is not null
and LongitudeEnderecoParada is not null
and PACOTES.datareferencia between @datainicio and @datafim

and rota.StatusRota <> 'planned'
and rota.excluido = 0 
and (pacotes.cidade is null  or pacotes.cidade = 'not_found' 
        or pacotes.cidade = '-' )
and (
        pacotes.IdTransportadora = @IdTransportadora
        or @IdTransportadora is null
     )

/*and rota.idrota =  283996049*/
;
;

    
    
    update a 
	set
		a.CidadeDistante = b.Cidade
	
	from tb_ml_rotas as a WITH (ROWLOCK, READPAST, UPDLOCK) 
	inner join 
	(
		select 
            DataReferencia,
			IdRota,
			idtransportadora,
			Cidade,
			ordem


		from
			(
				select 
                DataReferencia,
				idrota,
				idtransportadora,
                cidade
				, row_number() over(partition by idrota,idtransportadora order by cidadedistante) ordem
				from tb_ml_pacotes  nolock
                where cidadedistante >= 1
                and cidade is not null
                and cidade <> '-'
                and DataReferencia between @datainicio and @datafim
                and (
                        IdTransportadora = @IdTransportadora
                        or @IdTransportadora is null
                     )
     
    
			) as a
			where ordem = 1
	) as b
	 on a.idrota			= b.idrota 
  --  and a.DataReferencia    = b.datareferencia
	and a.idtransportadora  = b.idtransportadora

	where a.excluido = 0
	and (a.CidadeDistante is null  or a.CidadeDistante = 'not_found' 
    or a.CidadeDistante = '-' or a.CidadeDistante in('Sem pacote entregue', 'ERROR','Sem base cadastrada'))
    AND StatusRota not in ('planned' ,'canceled')


    --SELECT TOP 1000 * FROM tb_dra_cidades_geo ORDER BY dcg_cd_cidade_gei DESC
	


update a 
set a.cidadedistante = b.cidade
FROM TB_ML_ROTAS A 
inner join (
                select 
                *
                ,ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY cidadedistante) as rn 
                    from 
                    (

                select 
                    b.idrota
                    ,b.cidade 
                    ,b.cidadedistante
                from tb_ml_rotas as a
                inner join tb_ml_pacotes as b
                on a.idrota = b.idrota

                where a.dataReferencia between @datainicio and @datafim
                and a.cidadedistante = 'ERROR'
                and b.cidade is not null
                and a.excluido = 0
                and (
                        a.IdTransportadora = @IdTransportadora
                        or @IdTransportadora is null
                     )
                    
                    ) as a

                where a.cidadedistante IS NOT NULL 
                AND a.cidade <> 'ERROR'

) as b
on a.idrota = b.idrota
and rn = 1

where a.excluido = 0
and a.StatusRota <> 'planned'




update pacotes 
set cidade = geo.dcg_ds_cidade

from tb_ml_pacotes as pacotes with(nolock)
	left join tb_dra_cidades_geo as geo with(nolock)
	on pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
	and pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude
where 1=1
and LatitudeEnderecoParada is not null
	  and LongitudeEnderecoParada is not null
	--   and geo.dcg_cd_cidade_gei is null
	  and datareferencia between @datainicio and @datafim
      and pacotes.CidadeDistante >= 1
    --   and pacotes.idrota = 237865223
	  and pacotes.cidadedistante is not null 
	  and (pacotes.cidade is null or pacotes.cidade = 'ERROR')
	  and dcg_ds_cidade <> 'ERROR'
      and (
            pacotes.IdTransportadora = @IdTransportadora
            or @IdTransportadora is null
        )



end



GO
