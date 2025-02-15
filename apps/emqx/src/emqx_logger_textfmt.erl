%%--------------------------------------------------------------------
%% Copyright (c) 2021 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(emqx_logger_textfmt).

-export([format/2]).
-export([check_config/1]).

check_config(X) -> logger_formatter:check_config(X).

format(#{msg := {report, Report}, meta := Meta} = Event, Config) when is_map(Report) ->
    logger_formatter:format(Event#{msg := {report, enrich(Report, Meta)}}, Config);
format(#{msg := Msg, meta := Meta} = Event, Config) ->
    NewMsg = enrich_fmt(Msg, Meta),
    logger_formatter:format(Event#{msg := NewMsg}, Config).

enrich(Report, #{mfa := Mfa, line := Line}) ->
    Report#{mfa => mfa(Mfa), line => Line};
enrich(Report, _) -> Report.

enrich_fmt({Fmt, Args}, #{mfa := Mfa, line := Line}) when is_list(Fmt) ->
    {Fmt ++ " mfa: ~s line: ~w", Args ++ [mfa(Mfa), Line]};
enrich_fmt(Msg, _) ->
    Msg.

mfa({M, F, A}) -> atom_to_list(M) ++ ":" ++ atom_to_list(F) ++ "/" ++ integer_to_list(A).
