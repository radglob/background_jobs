FROM elixir:1.10-alpine AS build

RUN apk add --no-cache build-base npm

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV SECRET_KEY_BASE=nokey

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix deps.compile

COPY assets/package.json assets/package-lock.json ./assets/
RUN npm --prefix ./assets ci --progress false --no-audit --loglevel=error

COPY priv priv
COPY assets assets
RUN npm run --prefix ./assets deploy
RUN MIX_ENV=prod mix phx.digest

COPY lib lib
RUN MIX_ENV=prod mix release

FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/background_jobs ./

ADD entrypoint.sh ./

ENV HOME=/app
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE=nokey
ENV PORT=4000
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bin/background_jobs", "start"]
