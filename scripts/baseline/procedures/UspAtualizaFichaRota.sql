-- ============================================================
-- BASELINE: dbo.UspAtualizaFichaRota
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaFichaRota]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [dbo].[UspAtualizaFichaRota]
(
	@EmpresaID INT = null
	,@ano INT = null
	,@mes INT = null
	,@quinzena INT = null

) as


select CASE WHEN DAY(GETDATE()) >= 3 AND DAY(GETDATE()) <= 18 THEN 1 ELSE 2 END

DECLARE @ErrorMessage NVARCHAR(4000);

-- Declarar variáveis para ano, mês e quinzena

	set @ano = isnull(@ano, YEAR(GETDATE()));
	set @mes = isnull(@mes, MONTH(GETDATE()));
	set @quinzena = isnull(@quinzena,cASE WHEN DAY(GETDATE()) >= 3 AND DAY(GETDATE()) <= 18 THEN 1 ELSE 2 END);


-- Declarar um cursor para percorrer as linhas
DECLARE cursorEmpresas CURSOR FOR

select 
	cli_id_logistics as EmpresaID
    
from tb_clientes
where cli_ativo_financeiro = 1
and (cli_id_logistics = @EmpresaID or @EmpresaID is null)
and cli_id_logistics not in (1930706223,834780814)
--and cli_cd_codigo_cliente  not in (34)
--and cli_id_logistics = 2087146923

	
OPEN cursorEmpresas;

-- Variável para armazenar o ID da empresa atual
FETCH NEXT FROM cursorEmpresas INTO @EmpresaID;

-- Loop para executar as procedimentos para cada empresa
WHILE @@FETCH_STATUS = 0
BEGIN


	    EXEC UspGeraResultadoFinanceiro @EmpresaID, @ano, @mes, @quinzena;
      

    -- Avançar para a próxima empresa
    FETCH NEXT FROM cursorEmpresas INTO @EmpresaID;
END;

-- Fechar o cursor
CLOSE cursorEmpresas;
DEALLOCATE cursorEmpresas;
GO
