/*==============================================================================
  VALIDACAO — Dimensões dos relatórios web (forward 008)
  ==============================================================================
  Rode DEPOIS de aplicar 008_forward_dim_relatorios_web.sql (QAS primeiro).
  Todas as queries são SELECT read-only — seguras em qualquer ambiente.
  Objetos: dbo.vw_dim_base, dbo.vw_dim_cidade_ibge
  ==============================================================================*/

SET NOCOUNT ON;

/*------------------------------------------------------------------------------
  A) EXISTÊNCIA E CONTAGEM
------------------------------------------------------------------------------*/
SELECT name, type_desc, create_date
FROM sys.objects
WHERE name IN ('vw_dim_base', 'vw_dim_cidade_ibge')
ORDER BY name;

SELECT COUNT(*) AS total_bases_dim        FROM dbo.vw_dim_base;        -- esperado ~1.207
SELECT COUNT(*) AS total_cidades_dim      FROM dbo.vw_dim_cidade_ibge; -- esperado ~5.2k
SELECT COUNT(*) AS clientes_com_base      FROM (SELECT DISTINCT id_cliente FROM dbo.vw_dim_base) t; -- esperado ~69

/*------------------------------------------------------------------------------
  B) AMOSTRAS
------------------------------------------------------------------------------*/
SELECT TOP 20 * FROM dbo.vw_dim_base        ORDER BY base, id_transportadora;
SELECT TOP 20 * FROM dbo.vw_dim_cidade_ibge ORDER BY cidade;
SELECT TOP 30 * FROM dbo.vw_dim_cidade_ibge WHERE qtd_ufs > 1 ORDER BY cidade; -- nomes em >1 UF (~232)

/*------------------------------------------------------------------------------
  C) QUALIDADE — nulos, brancos, duplicidades
------------------------------------------------------------------------------*/
-- base nula/branca na dim (não pode ter — é o valor do WHERE)
SELECT COUNT(*) AS bases_sem_sigla FROM dbo.vw_dim_base WHERE base IS NULL OR LTRIM(RTRIM(base)) = '';

-- cidade nula/branca (view já filtra — deve vir 0)
SELECT COUNT(*) AS cidades_vazias FROM dbo.vw_dim_cidade_ibge WHERE cidade IS NULL OR cidade = '';

-- sigla repetida entre transportadoras (ESPERADO — a unicidade é transp.+sigla)
SELECT TOP 20 base, COUNT(*) AS qtd
FROM dbo.vw_dim_base
GROUP BY base HAVING COUNT(*) > 1
ORDER BY qtd DESC;

-- unicidade real da dim base: não pode existir (transportadora, sigla) duplicado
SELECT id_transportadora, base, COUNT(*) AS qtd
FROM dbo.vw_dim_base
GROUP BY id_transportadora, base
HAVING COUNT(*) > 1;   -- deve vir vazio

/*------------------------------------------------------------------------------
  D) CASCATA — Tenant (pgp_cd_cliente) x Base (bss_cod_cliente)
------------------------------------------------------------------------------*/
-- clientes com período de pagamento que TÊM base cadastrada (esperado ~37/38)
SELECT COUNT(DISTINCT b.id_cliente) AS clientes_com_periodo_e_base
FROM dbo.vw_dim_base b
WHERE EXISTS (SELECT 1 FROM dbo.tb_pgto_periodo pp WITH (NOLOCK)
              WHERE pp.pgp_cd_cliente = b.id_cliente);

-- bases por cliente (o que a cascata Tenant -> Base vai listar)
SELECT TOP 20 id_cliente, COUNT(*) AS qtd_bases
FROM dbo.vw_dim_base
GROUP BY id_cliente
ORDER BY qtd_bases DESC;

/*------------------------------------------------------------------------------
  E) COBERTURA CONTRA A FATO
------------------------------------------------------------------------------*/
-- siglas de base que aparecem nas rotas MAS não estão na dim (órfãs de filtro)
SELECT DISTINCT r.ServiceCenter AS base_fato_sem_dim
FROM dbo.vw_ml_rotas_financeiro r WITH (NOLOCK)
WHERE r.ServiceCenter IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.vw_dim_base d WHERE d.base = r.ServiceCenter);

-- cidades da fato que não existem na dim normalizada (~35% esperado: dado sujo
-- tipo "16800-000, Mirandópolis" não casa com o cadastro IBGE)
SELECT COUNT(DISTINCT r.CidadeDistante) AS cidades_fato_sem_dim
FROM dbo.tb_ml_rotas r WITH (NOLOCK)
WHERE r.CidadeDistante IS NOT NULL AND r.CidadeDistante <> ''
  AND NOT EXISTS (SELECT 1 FROM dbo.vw_dim_cidade_ibge d
                  WHERE d.cidade = LTRIM(RTRIM(r.CidadeDistante)));

/*------------------------------------------------------------------------------
  F) SIMULAÇÃO DO CONTRATO DO FILTRO (como o /api/filtros vai usar)
------------------------------------------------------------------------------*/
-- lista do select de Base por tenant (ex.: cliente 61):
SELECT base, base_label, uf
FROM dbo.vw_dim_base
WHERE id_cliente = 61
ORDER BY base;

-- lista do select de Cidade (label exibido, valor filtrado = cidade):
SELECT TOP 20 cidade_uf AS label, cidade AS valor
FROM dbo.vw_dim_cidade_ibge
ORDER BY cidade_uf;

-- o WHERE da fato NÃO muda: f.Base = @base  /  f.cidade = @cidade (parametrizado)
