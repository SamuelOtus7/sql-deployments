-- ============================================================
-- BASELINE: dbo.UspMLOcupacaoFrota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLOcupacaoFrota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLOcupacaoFrota]
    -- @data_inicio DATE,
    -- @data_fim DATE
AS
BEGIN
    SET NOCOUNT ON;
    

declare @data_inicio DATE = getdate()-1
declare @data_fim DATE = getdate()

drop table if exists #TempCarregamentoPorData;
    WITH placas_validas AS (
        SELECT DISTINCT r.placa, data_cadastro, TipoFrota, r.IdTransportadora, idcliente,  tipoveiculocad,vei_cd_veiculo,vei_ds_base as svc,r.servicecenter,
        case   
                    when  vei_in_frota_fixa = 3     then 'Própria - Veículo da transportadora'  
                    when  vei_in_frota_fixa = 2     then 'Fixa - Veículo alugado'  
                    when  vei_in_frota_fixa = 1     then 'Spot - Veículo do motorista'  
                    else 'Não informado'          
                end as CategoriaVeiculo
        FROM tb_ml_rotas AS r
        left JOIN (
            SELECT 
                b.cli_id_logistics,
                vei_cd_veiculo,
                a.vei_ds_placa AS placa,
                vei_Cd_ano,
                vei_ds_base,
                -- ISNULL(a.vei_in_tipo_frota, 0) AS tipoveiculocad,
                vei_ds_tipo AS tipoveiculocad,
                vei_dh_criacao AS data_cadastro,
                tf_nm_tipo_frota AS TipoFrota,
                cli_cd_codigo_cliente AS idcliente,
                vei_in_frota_fixa,
                case   
                    when  a.vei_in_frota_fixa = 3     then 'Própria - Veículo da transportadora'  
                    when  a.vei_in_frota_fixa = 2     then 'Fixa - Veículo alugado'  
                    when  a.vei_in_frota_fixa = 1     then 'Spot - Veículo do motorista'  
                    else 'Não informado'          
                end as CategoriaVeiculo

            FROM tb_veiculos AS a WITH (NOLOCK)
            INNER JOIN tb_clientes AS b WITH (NOLOCK) ON a.vei_cd_cliente = b.cli_cd_codigo_cliente
            LEFT JOIN tb_tipo_frota AS c WITH (NOLOCK) ON a.vei_in_tipo_frota = c.tf_cd_tipo_frota
            and cli_cd_codigo_cliente <> 7
          --  and cli_cd_codigo_cliente = 37
            and cli_in_ativo = 1
        ) AS veiculos ON veiculos.placa = r.placa
                     AND r.IdTransportadora = veiculos.cli_id_logistics
        WHERE datareferencia BETWEEN @data_inicio AND @data_fim
          AND excluido = 0
          AND StatusRota <> 'planned'
        --  and r.IdTransportadora = 678279205
          
    )


    -- Preenche tabela temporária
    SELECT  
        dt.data,
        dt.DiaDaSemana,
        CAST(pr.vei_dh_criacao AS DATE) AS DataCadastro,
        pr.vei_cd_cliente idtransportadora,
        pr.vei_cd_cliente idcliente,
        isnull(tf_nm_tipo_frota, 'Não informado') AS TipoFrota,
        p.CategoriaVeiculo,
        pr.vei_ds_placa as placa,
        isnull(p.tipoveiculocad,pr.vei_ds_tipo) AS tipoveiculo,
		pr.vei_ds_tipo tipoveiculocad,
        isnull(p.servicecenter,pr.vei_ds_base) AS servicecenter,
        r.NomeMotorista,
        pr.vei_cd_veiculo as codveiculo,
        
        -- CASE WHEN CAST(data_cadastro AS DATE) <= dt.data THEN p.placa ELSE NULL END AS placa_valida,
        CASE 
            WHEN fer.tfd_dh_feriado IS NULL THEN 
                CASE 
                    WHEN dt.DiaDaSemana <> 'domingo' THEN CASE WHEN CAST(pr.vei_dh_criacao AS DATE) <= dt.data THEN 1 ELSE 0 END
                    ELSE 0 END 
            ELSE 0 END AS DiasUteis,

        CASE 
            WHEN CAST(pr.vei_dh_criacao AS DATE) <= dt.data THEN CASE WHEN r.placa IS NOT NULL THEN 1 ELSE 0 END 
            ELSE NULL END AS carregamento,
        
        CASE 
            WHEN fer.tfd_dh_feriado IS NULL THEN 
                CASE 
                    WHEN dt.DiaDaSemana <> 'domingo' THEN 
                        CASE WHEN CAST(pr.vei_dh_criacao AS DATE) <= dt.data THEN CASE WHEN r.placa IS NOT NULL THEN 0 ELSE 1 END 
                            ELSE null END 
                    ELSE 0 END 
            ELSE 0 END AS Naocarregamento
				 ,format(r.DataHoraInicio, 'HH:mm') AS HoraInicio,
	case when DATEPART(hour,r.DataHoraInicio) < 12 then 'AM'
	  WHEN FORMAT(r.DataHoraInicio, 'HH:mm') BETWEEN '15:40' AND '17:30' THEN 'SD'
	  ELSE 'PM' end Ciclo
            -- 0 as rn
        
         --row_number() over (partition by dt.data,p.idtransportadora,r.placa  order by r.placa desc) as rn
        
    INTO #TempCarregamentoPorData

    FROM dimdata AS dt
    CROSS JOIN tb_veiculos AS pr
    LEFT JOIN tb_ml_rotas AS r ON dt.data = r.datareferencia
                               AND pr.vei_ds_placa = r.placa
                               AND r.excluido = 0
                               AND r.StatusRota <> 'planned'
    left JOIN placas_validas AS p
	on  pr.vei_ds_placa = p.Placa
	and pr.vei_cd_cliente = p.idcliente

    LEFT JOIN tb_tipo_frota AS c WITH (NOLOCK) ON pr.vei_in_tipo_frota = c.tf_cd_tipo_frota
	
    LEFT JOIN tb_feriados AS fer ON dt.data = fer.tfd_dh_feriado
                                AND fer.tfd_cd_cliente = pr.vei_cd_cliente
    
	WHERE 1=1 
	and dt.data BETWEEN @data_inicio AND @data_fim
    and pr.vei_ds_placa is not null
	--and vei_cd_cliente = 37
	--and  pr.vei_ds_placa IN ('SQZ4D18');

   drop table if exists #TempCarregamentoPorData2;
select
 row_number() over (partition by data,idtransportadora,placa  order by placa desc) as rn
,*
into #TempCarregamentoPorData2
from #TempCarregamentoPorData 

--where TipoFrota = 'Fixa - Veículo alugado'
-- and placa = 'SQZ4D18'


delete from #TempCarregamentoPorData2 where rn > 1



--delete  from #TempCarregamentoPorData2 where idtransportadora is  NULL
    MERGE dbo.tb_ml_ocupacao_frota AS target
    USING #TempCarregamentoPorData2 AS source
    ON target.data = source.data AND target.placa = source.placa
    and target.idcliente = source.idcliente

    WHEN MATCHED THEN 
        UPDATE SET 
            DiasUteis = source.DiasUteis,
            carregamento = source.carregamento,
            Naocarregamento = source.Naocarregamento,
            TipoFrota = source.TipoFrota,
            CategoriaVeiculo = source.CategoriaVeiculo,
            NomeMotorista = source.NomeMotorista,
            tipoveiculocad = source.tipoveiculocad,
            tipoveiculo = source.tipoveiculo,
            DataAtualizacao = getdate(),
            codveiculo =  source.codveiculo,
			target.ciclo = source.ciclo


    WHEN NOT MATCHED THEN
        INSERT (
            data, DiaDaSemana, DataCadastro, idtransportadora, idcliente, placa, tipoveiculo,
            servicecenter, DiasUteis, carregamento, Naocarregamento,TipoFrota,CategoriaVeiculo,NomeMotorista , tipoveiculocad
			,codveiculo,ciclo
        )
        VALUES (
            source.data, source.DiaDaSemana, source.DataCadastro, source.idtransportadora, source.idcliente,
            source.placa, source.tipoveiculo, source.servicecenter, 
            source.DiasUteis, source.carregamento, source.Naocarregamento, source.TipoFrota, source.CategoriaVeiculo, source.NomeMotorista ,source.tipoveiculocad,
            source.codveiculo,source.ciclo
        );

END


--select * from #TempCarregamentoPorData2
GO
