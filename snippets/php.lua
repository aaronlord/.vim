require('luasnip.session.snippet_collection').clear_snippets('php')

local ls = require('luasnip')

local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node

local rep = require('luasnip.extras').rep

local fmt = require('luasnip.extras.fmt').fmt

local namespace = function()
    return vim.fn.substitute(
        vim.fn.substitute(
            vim.fn.substitute(
                vim.fn.expand('%:p:h'),
                vim.fn.getcwd() .. '/',
                '',
                ''
            ),
            '/',
            '\\',
            'g'
        ),
        '^.',
        '\\U&',
        ''
    )
end

local classname = function()
    return vim.fn.expand('%:t:r')
end

local it_with = function(args)
    local arg = args[1][1] or ""

    if arg == "" then
        return sn(nil, t(""))
    end

    local parts = vim.split(arg, ',', true)

    for n, part in ipairs(parts) do
        local p = vim.split(part:gsub('^%s+', ''):gsub('%s+$', ''), ' ', true)

        p = #p == 1 and p[1] or p[2]

        parts[n] = p:gsub('^%$', '')
    end

    if #parts == 0 then
        return ""
    end

    -- TODO:
    -- I want to dynamically generate the template and arguments from the parts
    return sn(nil, fmt([[->with([
    '{}' => {},
    {}
])]], {
        i(1, arg),
        i(2, 'null'),
        i(0, '')
    }))
end


ls.add_snippets('php', {
    s('php', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        {}
    ]], {
        namespace = f(namespace, {}),
        i(0, '//..')
    })),

    s('interface', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        interface {classname}
        {{
            {}
        }}
    ]], {
        i(0, '//..'),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
    })),

    s('trait', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        trait {classname}
        {{
            {}
        }}
    ]], {
        i(0, '//..'),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
    })),

    s('class', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        class {classname}
        {{
            {}
        }}
    ]], {
        i(0, '//..'),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
    })),

    s('dto', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        final readonly class {classname}
        {{
            public function __construct(
                public {scalar} ${property},{}
            ) {{
            }}
        }}
    ]], {
        i(0),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
        scalar = i(1, 'string'),
        property = i(2, 'property'),
    })),

    s('vo', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        final readonly class {classname}
        {{
            public function __construct(
                public {scalar} ${property},{}
            ) {{
            }}

            public function equals({classname} $that): bool
            {{
                return $this->{_property} === $that->{_property};
            }}
        }}
    ]], {
        i(0),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
        scalar = i(1, 'string'),
        property = i(2, 'property'),
        _property = rep(2),
    })),

    s('idvo', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        use App\Shared\Domain\ValueObjects\Traits\IdTrait;

        final readonly class {classname}
        {{
            use IdTrait;{}
        }}
    ]], {
        i(0),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
    })),

    s('action', fmt([[
        <?php

        declare(strict_types=1);

        namespace {namespace};

        class {classname}
        {{
            public function {method}({args}): {ret}
            {{
                {}
            }}
        }}
    ]], {
        i(0, '//..'),
        method = c(1, {
            t('handle'),
            t('execute'),
        }),
        args = i(2, ''),
        ret = i(3, 'void'),
        namespace = f(namespace, {}),
        classname = f(classname, {}),
    })),

    s('method', fmt([[
        {access} function {name}({args}): {ret}
        {{
            {}
        }}
    ]], {
        i(0, '//..'),
        access = c(1, {
            t('public'),
            t('protected'),
            t('private'),
        }),
        name = i(2, 'method'),
        args = i(3, ''),
        ret = i(4, 'void'),
    })),

    s('__construct', fmt([[
        public function __construct(
            {}
        ) {{
        }}
    ]], {
        i(0, '//..'),
    })),

    s('describe', fmt([[
        describe('{feature}', function () {{
            {}
        }});
    ]], {
        feature = i(1, 'a feature'),
        i(0, '//..'),
    })),

    s('it', fmt([[
        it('{}', function ({}) {{
            {}
        }}){};
    ]], {
        i(1),
        i(2),
        i(0, '//..'),
        d(3, it_with, { 2 }),

        -- f(function(args)
        --     local arg = args[1][1] or ''
        --
        --     if arg == '' then
        --         return ''
        --     end
        --
        --     local parts = vim.split(arg, ',', true)
        --
        --     for n, part in ipairs(parts) do
        --         local p = vim.split(part:gsub('^%s+', ''):gsub('%s+$', ''), ' ', true)
        --
        --         p = #p == 1 and p[1] or p[2]
        --
        --         parts[n] = "'" .. p:gsub('^%$', '') .. "' => null,"
        --     end
        --
        --     if #parts == 0 then
        --         return ""
        --     end
        --
        --     return "->with([[" .. table.concat(parts, ' '):gsub(',$', '') .. "]])"
        -- end, { 2 })
    })),
})
