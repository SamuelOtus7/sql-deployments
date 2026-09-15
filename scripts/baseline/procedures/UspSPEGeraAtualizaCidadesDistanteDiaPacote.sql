-- ============================================================
-- BASELINE: dbo.UspSPEGeraAtualizaCidadesDistanteDiaPacote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEGeraAtualizaCidadesDistanteDiaPacote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspSPEGeraAtualizaCidadesDistanteDiaPacote] as

begin

declare @datainicio date = getdate()-15
declare @datafim date = getdate()

BEGIN
    WITH CTE AS (
        SELECT 
            p.Id -- ou outra chave primária da tabela `tb_ml_pacotes`
        FROM tb_spe_pacotes_v5 p WITH (NOLOCK)
        LEFT JOIN tb_dra_cidades_geo geo WITH (NOLOCK)
            ON p.Latitude = geo.dcg_nr_latitude
            AND p.Longitude = geo.dcg_nr_longitude
        WHERE
            p.Excluido = 0
            AND p.DataReferencia BETWEEN @datainicio AND @datafim
            AND p.cidadedistante = 1
            AND geo.dcg_ds_cidade IS NOT NULL
            AND (p.Cidade IS NULL or p.Cidade in ('Sem pacote entregue','Sem base cadastrada'))

    )


    UPDATE p
    SET Cidade = case when geo.dcg_ds_cidade = 'NOT_FOUND' then dcg_ds_village else geo.dcg_ds_cidade end 
    FROM tb_spe_pacotes_v5 p WITH  (ROWLOCK, READPAST, UPDLOCK) 
    INNER JOIN CTE ON p.Id = CTE.Id
    LEFT JOIN tb_dra_cidades_geo geo WITH (NOLOCK)
        ON p.Latitude = geo.dcg_nr_latitude
        AND p.Longitude = geo.dcg_nr_longitude;

END

    
    
    update a 
	set
		a.CidadeDistante = b.Cidade
	
	from tb_spe_rotas_v5 as a WITH (ROWLOCK, READPAST, UPDLOCK) 
	inner join 
	(
		select 
            DataReferencia,
			codigorota,
			idtransportadora,
			Cidade,
			ordem


		from
			(
				select 
                DataReferencia,
				codigorota,
				idtransportadora,
                cidade
				, row_number() over(partition by codigorota order by cidadedistante) ordem
				from tb_spe_pacotes_v5  nolock
                where cidadedistante >= 1
                and cidade is not null
                and DataReferencia between @datainicio and @datafim
                
			) as a
			where ordem = 1
	) as b
	 on a.codigorota			= b.codigorota 
  --  and a.DataReferencia    = b.datareferencia
	and a.idtransportadora  = b.idtransportadora
    
	where a.excluido = 0
	and (a.CidadeDistante is null or a.CidadeDistante in ('Sem pacote entregue','Sem base cadastrada'))
	
	

end


GO
