using Genie
using Genie.Router
using Genie.Renderer
using Guard, Guard.Configuration

const options = Configuration.Options(;
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000/oauth2/google/callback",
    success_redirect="/yes",
    failure_redirect="/no",
    scopes=["profile", "openid", "email"]
)

const githubOptions = Configuration.Options(;
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000/oauth2/github/callback",
    success_redirect="/yes",
    failure_redirect="/no",
    scopes=["user"]
)

google_oauth2 = Guard.init(:google, options, Genie.Renderer.redirect)
github_oauth2 = Guard.init(:github, githubOptions, Genie.Renderer.redirect)

route("/") do
    return """
        <a href="/oauth2/google">Authenticate with Google</a>
        <br/>
        <a href="/oauth2/github">Authenticate with GitHub</a>
    """
end

route("/oauth2/google") do
    google_oauth2.redirect()
end

route("/oauth2/github") do
    github_oauth2.redirect()
end

route("/oauth2/google/callback") do
    code = Genie.params(:code, nothing)
    function verify(tokens::Guard.Google.Tokens, user::Guard.Google.User)
        println(tokens.access_token)
        println(user.email)
    end

    google_oauth2.token_exchange(code, verify)
end

route("/oauth2/github/callback") do
    code = Genie.params(:code, nothing)
    function verify(tokens::Guard.GitHub.Tokens, user::Guard.GitHub.User)
        println(tokens.access_token)
        println(user.name)
    end

    github_oauth2.token_exchange(code, verify)
end

route("/yes") do
    return "234"
end

route("/no") do
    return "no"
end

up(3000, async=false)