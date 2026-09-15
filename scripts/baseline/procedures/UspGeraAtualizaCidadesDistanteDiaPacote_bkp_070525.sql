-- ============================================================
-- BASELINE: dbo.UspGeraAtualizaCidadesDistanteDiaPacote_bkp_070525
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote_bkp_070525]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[UspGeraAtualizaCidadesDistanteDiaPacote_bkp_070525] as

begin

declare @datainicio date = cast(getdate()-1 as date)
declare @datafim date = cast(getdate() as date)

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
				, row_number() over(partition by idrota order by cidadedistante) ordem
				from tb_ml_pacotes  nolock
                where cidadedistante >= 1
                and cidade is not null
                and DataReferencia between @datainicio and @datafim
                
			) as a
			where ordem = 1
	) as b
	 on a.idrota			= b.idrota 
  --  and a.DataReferencia    = b.datareferencia
	and a.idtransportadora  = b.idtransportadora
    
	where a.excluido = 0
	and a.CidadeDistante is null
	
	

end


GO
