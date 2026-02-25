package org.ngcvfb.inventorymanagementapi.config;

import graphql.GraphQLContext;
import graphql.execution.CoercedVariables;
import graphql.language.IntValue;
import graphql.language.Value;
import graphql.schema.*;
import org.springframework.context.annotation.Configuration;
import org.springframework.graphql.execution.RuntimeWiringConfigurer;

import java.util.Locale;

@Configuration
public class GraphQLScalarConfig implements RuntimeWiringConfigurer {

    private static final GraphQLScalarType LONG_SCALAR = GraphQLScalarType.newScalar()
            .name("Long")
            .description("Java Long scalar type")
            .coercing(new Coercing<Long, Long>() {
                @Override
                public Long serialize(Object result, GraphQLContext ctx, Locale locale)
                        throws CoercingSerializeException {
                    if (result instanceof Long l) return l;
                    if (result instanceof Number n) return n.longValue();
                    try { return Long.parseLong(result.toString()); }
                    catch (NumberFormatException e) {
                        throw new CoercingSerializeException("Cannot serialize " + result + " as Long");
                    }
                }

                @Override
                public Long parseValue(Object input, GraphQLContext ctx, Locale locale)
                        throws CoercingParseValueException {
                    if (input instanceof Long l) return l;
                    if (input instanceof Number n) return n.longValue();
                    try { return Long.parseLong(input.toString()); }
                    catch (NumberFormatException e) {
                        throw new CoercingParseValueException("Cannot parse value " + input + " as Long");
                    }
                }

                @Override
                public Long parseLiteral(Value<?> input, CoercedVariables variables,
                                         GraphQLContext ctx, Locale locale)
                        throws CoercingParseLiteralException {
                    if (input instanceof IntValue iv) return iv.getValue().longValueExact();
                    throw new CoercingParseLiteralException("Cannot parse literal " + input + " as Long");
                }
            })
            .build();

    @Override
    public void configure(graphql.schema.idl.RuntimeWiring.Builder builder) {
        builder.scalar(LONG_SCALAR);
    }
}
