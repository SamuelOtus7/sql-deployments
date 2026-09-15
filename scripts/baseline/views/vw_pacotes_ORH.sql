-- ============================================================
-- BASELINE: dbo.vw_pacotes_ORH
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_ORH]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[vw_pacotes_ORH]
AS
SELECT 
    Id,
    IdPacote,
	SequenciaParada,
    IdRota,
    IdTransportadora,
    DataReferencia,
	DataHoraEntrega,
	DATEPART(HOUR, DataHoraEntrega) AS Hora,
    CAST(DataHoraEntrega AS date) AS DataEntrega,
    CONVERT(time(0), DataHoraEntrega) AS HoraEntrega,
	(DATEPART(HOUR, p.DataHoraEntrega) * 100)
+ (DATEPART(MINUTE, p.DataHoraEntrega) / 15) * 15 AS SKTempo_15,
    case when trim(t.tds_ds_traducao) in('Entregue','Entregue - Place') or t.tds_ds_traducao like 'Transferido para a rota%' then 'Sucesso'
		     when trim(t.tds_ds_traducao) in ('Chegando ao Destino','Pendente','Em rota de entrega','Para expedir') then 'Em Andamento'
			 else 'Insucesso'
		end as StatusGeralEntrega,
    case  
        when t3.tds_ds_traducao = 'Endereço Ruim' then 'Endereço inválido'
        when t3.tds_ds_traducao = 'Erro de Rota' then 'Fora de Área'
        else isnull(t3.tds_ds_traducao,'Não Categorizado') end  SubStatus,
    t.tds_ds_traducao StatusEntrega
FROM tb_ml_pacotes p
left join tb_ml_traducoes t on p.StatusEntrega = t.tds_vl_json and t.tds_nm_tabela = 'tb_ml_pacotes' and t.tds_nm_campo = 'StatusEntrega'
left join tb_ml_traducoes t3 on p.SubStatus = t3.tds_vl_json and t3.tds_nm_tabela = 'tb_ml_pacotes' and t3.tds_nm_campo = 'SubStatus' 
WHERE
    datareferencia >= DATEADD(DAY, -3, CAST(GETDATE() AS date));
GO
