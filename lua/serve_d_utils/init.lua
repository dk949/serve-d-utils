---This file provides a thin wrapper around various custom requests and
---notifications provided by serve-d.
---
---Start by creating a `ServeD` object with `ServeD.new()`
---
---`ServeD` provides 4 types of methods:
--- * Send request:
---     These methods return `ErrorOr<T>` with T being the result of the request
--- * Send notification:
---     These methods return `boolean`. If the boolean is `false`, the client has crashed
--- * Receive request:
---     These methods start with an `on` prefix and take a handler which should return a value.
--- * Receive notification:
---     These methods start with an `on` prefix and take a handler which should not return anything
---
--- NOTE: Handler functions may optionally return an error object created with
---       `vim.lsp.rpc.rpc_response_error()` as their second return value.
---       In this case notification receiving functions should return `nil` as
---       their first return value


---@alias ProgressToken integer|string
---@alias DocumentUri string
---@alias size_t integer
--- Key: URI folder or file in which startup issues occured. (compare with startsWith)
--- Value: human readable message.
---@alias PendingErrors table<string, string>

---Key: module, Value: modules that depend on the (key) module.
---This is only the module index for the active workspace.
---@alias ModuleIndex table<string, string>

---@class ErrorOr<T> : {err : lsp.ResponseError?, result : T? }
---@alias HandlerFor<T, Ret> fun(err: lsp.ResponseError, result: T?, ctx: lsp.HandlerContext) : Ret, lsp.ResponseError?

---@class (exact) TextDocumentIdentifier
---@field uri DocumentUri @ The text document's URI

---@class (exact) TextEdit
---@field range Range @ The range of the text document to be manipulated. To insert text into a document, create a range where start === end.
---@field newText string @ The string to be inserted. For delete operations, use an empty string.

---@class (exact) SortImportsParams
---@field textDocument TextDocumentIdentifier @ Text document to look in
---@field location number @ Location of cursor as standard offset, -1 for entire document

---@class (exact) ImplementMethodsParams
---@field textDocument TextDocumentIdentifier @ Text document to look in
---@field location number @ Location of cursor as standard offset

---@class (exact) ListArchTypesParams
---@field withMeaning? boolean @ If true, return ArchTypeInfo[] with meanings instead of string[]

---@class (exact) ArchTypeInfo
---@field value string @ The value to use with a switchArchType call / the value DUB uses
---@field label string|nil @ If not nil, show this string in the UI rather than value

---@class (exact) AddImportParams
---@field textDocument TextDocumentIdentifier @ Text document to look in
---@field name string @ The name of the import to add
---@field location number @ Location of cursor as standard offset
---@field insertOutermost? boolean @ If `false`, the import will get added to the innermost block (default is `true`)

---@class (exact) ImportModification
---@field rename string @ Set if there was already an import which was renamed (e.g., `import io = std.stdio;` would be "io")
---@field replacements CodeReplacement[] @ Array of replacements to add the import to the code

---@class (exact) CodeReplacement
---@field range [size_t,size_t] @ Range to replace. If both indices are the same, it inserts. Specified as byte offsets from the UTF-8 source.
---@field content string @ Content to replace it with. Empty means remove.

---@class (exact) UpdateImportsParams
---@field reportProgress? boolean @ Set this to false to not emit progress updates for the UI

---@class (exact) DubDependency
---@field name string @ The name of this package
---@field version string @ The installed version of this dependency or nil if it isn't downloaded/installed yet
---@field path string @ Path to the directory in which the package resides or nil if it's not stored in the local file system
---@field description string @ Description as given in dub package file
---@field homepage string @ Homepage as given in dub package file
---@field authors string[] @ Authors as given in dub package file
---@field copyright string @ Copyright as given in dub package file
---@field license string @ License as given in dub package file
---@field subPackages string[] @ List of the names of subPackages as defined in the package
---@field hasDependencies boolean @ `true` if this dependency has other dependencies
---@field root boolean @ `true` if no package name was given and thus this dependency is a root dependency of the active project

---@class (exact) Task
---@field definition any @ The default JSON task
---@field scope string @ Global | workspace | URI of workspace folder
---@field exec string[] @ Command to execute
---@field name string @ Name of the task
---@field isBackground boolean @ `true` if this is a background task without shown console
---@field source string @ Task source extension name
---@field group TaskGroup @ Task group (clean, build, rebuild, test)
---@field problemMatchers string[] @ Problem matchers to use

---@class (exact) DubConvertRequest
---@field textDocument TextDocumentIdentifier @ Text document to look in
---@field newFormat string @ The format to convert the dub recipe to (json, sdl)

---@class (exact) InstallRequest
---@field name string @ Name of the dub dependency
---@field version string @ Version to install in the dub recipe file

---@class (exact) UpdateRequest
---@field name string @ Name of the dub dependency
---@field version string @ Version to install in the dub recipe file

---@class (exact) UninstallRequest
---@field name string @ Name of the dub dependency

---@class (exact) DocumentLinkParams
---@field textDocument TextDocumentIdentifier @ The document to provide document links for
---@field workDoneToken? ProgressToken @ An optional token that a server can use to report work done progress
---@field partialResultToken? ProgressToken @ An optional token that a server can use to report partial results (e.g. streaming) to the client

---@class (exact) DScannerIniSection
---@field description string @ A textual human-readable description of the section
---@field name string @ The name of the section as written in the ini
---@field features DScannerIniFeature[] @ Features which are children of this section

---@class (exact) DScannerIniFeature
---@field description string @ A textual human-readable description of the value
---@field name string @ The name of the value
---@field enabled "'disabled'"|"enabled"|"skip-unittest" @ Enables/disables the feature or enables it with being disabled in unittests

---@class DubConfig @ not exact, may contain other useful fields
---@field packagePath string @ Path to the package
---@field packageName string @ Name of the package
---@field targetPath string @ Path to the target
---@field targetName string @ Name of the target
---@field workingDirectory string @ Working directory
---@field mainSourceFile string @ Main source file
---@field dflags string[] @ D flags
---@field lflags string[] @ L flags
---@field libs string[] @ Libraries
---@field linkerFiles string[] @ Linker files
---@field sourceFiles string[] @ Source files
---@field copyFiles string[] @ Files to copy
---@field versions string[] @ Versions
---@field debugVersions string[] @ Debug versions
---@field importPaths string[] @ Import paths
---@field stringImportPaths string[] @ String import paths
---@field importFiles string[] @ Import files
---@field stringImportFiles string[] @ String import files
---@field preGenerateCommands string[] @ Pre-generate commands
---@field postGenerateCommands string[] @ Post-generate commands
---@field preBuildCommands string[] @ Pre-build commands
---@field postBuildCommands string[] @ Post-build commands
---@field preRunCommands string[] @ Pre-run commands
---@field postRunCommands string[] @ Post-run commands

---@class (exact) ProfileGCEntry
---@field bytesAllocated number @ Bytes allocated
---@field allocationCount number @ Allocation count
---@field type string @ The function and/or type name
---@field uri string @ Absolute, normalized URI
---@field displayFile string @ As parsed from file
---@field line number @ 1-based line number

---@class (exact) DidChangeConfigurationParams
---@field settings any

---@class (exact) ServerInfo
---@field name string @ The name of the server as defined by the server.
---@field version string? @ The server's version as defined by the server.

---@class (exact) WorkspaceState
---@field uri string @ URI to the workspace folder
---@field name string @ name of the workspace folder (or internal placeholder)
---@field initialized boolean @ true if this instance has been initialized
---@field selected boolean @ true if this is the active instance
---@field pendingErrors PendingErrors @ May contain errors that are pending and will be shown once the user with this workspace.

---@class (exact) ServedInfoParams
---@field includeConfig boolean?
---@field includeIndex boolean?
---@field includeTasks boolean?

---@class (exact) RunningTask
---@field name string @ task name (in most cases function name or LSP request name)
---@field queued number @ Number of seconds before now (float) when the task was queued
---@field started number @ Number of seconds before now (float) when the task was first started
---@field ended number @ Number of seconds before now (float) when the task ended - 0 for running tasks
---@field running boolean @ true if currently ongoing (e.g. yielding)
---@field numSteps number @ Number of (re)entries
---@field timeSpent number @ Number of seconds that this fiber was running in total

---@class ServedInfoResponse
---@field serverInfo ServerInfo @ Same as in the initialized response. (the LSP server info)
---@field currentConfiguration any? @ Only included if ServedInfoParams.includeConfig is true. Contains the entire config object.
---@field moduleIndex ModuleIndex? @ Only included if ServedInfoParams.includeIndex is true.
---@field globalWorkspace WorkspaceState @ Describes the global workspace, same type as in coded/changedSelectedWorkspace
---@field workspaces WorkspaceState[] @ Describes all available workspaces.
---@field selectedWorkspaceIndex number @ First index inside the workspaces array sent along this value, where selected is set to true, or -1 for global workspace.
---@field runningTasks RunningTask[] @ Only included if ServedInfoParams.includeTasks is true. List of currently running and recently done LSP requests and tasks

---@class UpdateSettingParams
---@field section string @ The configuration section to update in (e.g. "d" or "dfmt")
---@field value any @ The value to set the configuration value to
---@field global boolean `true` if this is a configuration change across all instances and not just the active one

---@class SkippedLoadsNotification
---@field roots string[] @ List of folder file paths

---@class InteractiveDownload
---@field url string @ The URL to download
---@field title string? @ The title to show in the UI popup for this download
---@field output string @ The file path to write the downloaded file to


---@class NewOptions
---@field client vim.lsp.Client? serve-d client to use, looks for client named "serve_d" by default
---@field timeout integer? timeout for sending requests, uses neovim defaults by default
---@field quiet_error boolean? if `new` cannot find a client return `nil` (throws an `error` if false, default `true`)

---@class (exact) ServeD
---@field private serve_d vim.lsp.Client
---@field public timeout integer?
---@field public new fun(opts: NewOptions?): ServeD?
---@field public unwrap fun(e: ErrorOr<`T`>, default: `T`?): `T`
---@field public errCodeToStr fun(code: integer?): string
---@field public TaskGroup table<string, string>
---@field public ErrorCodes table<string, integer>
---@field public IGNORE_ERROR vim.NIL
---@field protected runRequest fun(self: ServeD , method: string , param: table? , bufnr: integer? , callback: lsp.Handler?): table|integer
---@field protected sendNotification fun(self: ServeD , method: string , param: table?): boolean
---@field public sortImports fun(self: ServeD , param: SortImportsParams , bufnr: integer?): ErrorOr<TextEdit[]>
---@field public implementMethods fun(self: ServeD , param: ImplementMethodsParams , bufnr: integer?): ErrorOr<TextEdit[]>
---@field public restartServer fun(self: ServeD , bufnr: integer?): ErrorOr<boolean>
---@field public killServer fun(self: ServeD): boolean
---@field public updateDCD fun(self: ServeD): boolean
---@field public listConfigurations fun(self: ServeD , bufnr: integer?): ErrorOr<string[]>
---@field public switchConfig fun(self: ServeD , param: string , bufnr: integer?): ErrorOr<boolean>
---@field public getConfig fun(self: ServeD , bufnr: integer?): ErrorOr<string>
---@field public listArchTypes fun(self: ServeD , param: ListArchTypesParams , bufnr: integer?): ErrorOr<string[] | ArchTypeInfo[]>
---@field public switchArchType fun(self: ServeD , param: string , bufnr: integer?): ErrorOr<boolean>
---@field public getArchType fun(self: ServeD , bufnr: integer?): ErrorOr<string>
---@field public listBuildTypes fun(self: ServeD , bufnr: integer?): ErrorOr<string[]>
---@field public switchBuildType fun(self: ServeD , param: string , bufnr: integer?): ErrorOr<boolean>
---@field public getBuildType fun(self: ServeD , bufnr: integer?): ErrorOr<string>
---@field public getCompiler fun(self: ServeD , bufnr: integer?): ErrorOr<string>
---@field public switchCompiler fun(self: ServeD , param: string , bufnr: integer?): ErrorOr<boolean>
---@field public addImport fun(self: ServeD , param: AddImportParams , bufnr: integer?): ErrorOr<ImportModification>
---@field public updateImports fun(self: ServeD , param: UpdateImportsParams , bufnr: integer?): ErrorOr<boolean>
---@field public listDependencies fun(self: ServeD , param: string , bufnr: integer?): ErrorOr<DubDependency[]>
---@field public buildTasks fun(self: ServeD , bufnr: integer?): ErrorOr<Task[]>
---@field public convertDubFormat fun(self: ServeD , param: DubConvertRequest): boolean
---@field public installDependency fun(self: ServeD , param: InstallRequest): boolean
---@field public updateDependency fun(self: ServeD , param: UpdateRequest): boolean
---@field public uninstallDependency fun(self: ServeD , param: UninstallRequest): boolean
---@field public searchFile fun(self: ServeD , query: string , bufnr: integer?): ErrorOr<string[]>
---@field public findFilesByModule fun(self: ServeD , module: string , bufnr: integer?): ErrorOr<string[]>
---@field public getDscannerConfig fun(self: ServeD , param: DocumentLinkParams , bufnr: integer?): ErrorOr<DScannerIniSection[]>
---@field public getActiveDubConfig fun(self: ServeD , bufnr: integer?): ErrorOr<DubConfig>
---@field public getProfileGCEntries fun(self: ServeD , bufnr: integer?): ErrorOr<ProfileGCEntry[]>
---@field public getInfo fun(self: ServeD , param: ServedInfoParams , bufnr: integer?): ErrorOr<ServedInfoResponse>
---@field public forceLoadProjects fun(self: ServeD , param: string[] , bufnr: integer?): ErrorOr<boolean[]>
---@field public didChangeConfiguration fun(self: ServeD , param: DidChangeConfigurationParams): boolean
---@field public doDscanner fun(self: ServeD , param: DocumentLinkParams): boolean
---@field public onUpdateSerring fun(self: ServeD , callback: HandlerFor<UpdateSettingParams, nil>): nil
---@field public onLogInstall fun(self: ServeD , callback: HandlerFor<string, nil>): nil
---@field public onInitDubTree fun(self: ServeD , callback: HandlerFor<nil, nil>): nil
---@field public onUpdateDubTree fun(self: ServeD , callback: HandlerFor<nil, nil>): nil
---@field public onChangedSelectedWorkspace fun(self: ServeD , callback: HandlerFor<WorkspaceState, nil>): nil
---@field public onSkippedLoads fun(self: ServeD , callback: HandlerFor<SkippedLoadsNotification, nil>): nil
---@field public onInteractiveDownload fun(self: ServeD , callback: HandlerFor<InteractiveDownload, boolean>): nil

local ServeD = {}

---@enum TaskGroup
ServeD.TaskGroup = {
    clean = "clean",
    build = "build",
    rebuild = "rebuild",
    test = "test",
}

---@enum ErrorCodes
ServeD.ErrorCodes = {
    ParseError           = -32700,
    InvalidRequest       = -32600,
    MethodNotFound       = -32601,
    InvalidParams        = -32602,
    InternalError        = -32603,
    ServerNotInitialized = -32002,
    UnknownErrorCode     = -32001,
    RequestFailed        = -32803,
    ServerCancelled      = -32802,
    ContentModified      = -32801,
    RequestCancelled     = -32800,
}

ServeD.IGNORE_ERROR = vim.NIL


---Find the serve_d client
---@return vim.lsp.Client?
local function getClient()
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        if client.name == "serve_d" then
            return client
        end
    end
end


---Wraps the serve-d client
---Will look through all connected clients until it finds one with the name "serve_d"
---Use the `client` to override
---Returns `nil` if client cannot be found
---@param opts NewOptions?
---@return ServeD?
function ServeD.new(opts)
    if opts == nil then
        opts = {}
    end
    local serve_d
    if opts.client == nil then
        serve_d = getClient()
    else
        serve_d = opts.client
    end
    if serve_d then
        local new_serve_d = vim.fn.deepcopy(ServeD, false)
        new_serve_d.serve_d = serve_d
        new_serve_d.timeout = opts.timeout
        return new_serve_d
    elseif opts.quiet_error == nil or opts.quiet_error == true then
        return nil
    else
        error("Could not find serve_d client")
    end
end

---Converts an error code from the `lsp.ResponseError` to a string
---@param code integer?
---@return string
function ServeD.errCodeToStr(code)
    if code == nil then
        return "Client error"
    elseif code == ServeD.ErrorCodes.ParseError then
        return "RPC: Parse error"
    elseif code == ServeD.ErrorCodes.InvalidRequest then
        return "RPC: Invalid request"
    elseif code == ServeD.ErrorCodes.MethodNotFound then
        return "RPC: Method not found"
    elseif code == ServeD.ErrorCodes.InvalidParams then
        return "RPC: Invalid params"
    elseif code == ServeD.ErrorCodes.InternalError then
        return "RPC: Internal error"
    elseif code == ServeD.ErrorCodes.ServerNotInitialized then
        return "LSP: Server not initialized"
    elseif code == ServeD.ErrorCodes.UnknownErrorCode then
        return "LSP: Unknown error code"
    elseif code == ServeD.ErrorCodes.RequestFailed then
        return "LSP: Request failed"
    elseif code == ServeD.ErrorCodes.ServerCancelled then
        return "LSP: Server cancelled"
    elseif code == ServeD.ErrorCodes.ContentModified then
        return "LSP: Content modified"
    elseif code == ServeD.ErrorCodes.RequestCancelled then
        return "LSP: Request cancelled"
    else
        return "Unknown error code " .. tostring(code)
    end
end

---If there is no error, return the response
---If there is an error, return the default value
---If default value is `nil` throw an error
---To explicitly ignore an error with `unwrap`, use `ServeD.IGNORE_ERROR` as the default value
---@generic T
---@param e ErrorOr<T>
---@param default T|vim.NIL?
---@return T
function ServeD.unwrap(e, default)
    if e.err then
        if default ~= nil then return default end
        error(ServeD.errCodeToStr(e.err.code) .. ": " .. e.err.message, 2)
    end
    return e.result
end

---comment
---@param method string
---@param param table?
---@param bufnr integer?
---@param callback lsp.Handler?
---@return table|integer
function ServeD:runRequest(method, param, bufnr, callback)
    assert(self ~= nil, "why is self nil")
    assert(self.serve_d ~= nil, "why is serve_d nil")

    ---`request_sync` is not typed correctly, it _does_ accept nil for `bufnr`
    ---@cast bufnr integer

    if callback then
        local success, req = self.serve_d.request(method, param);
        if not success then
            return {
                err = {
                    code = nil,
                    message = "client has shutdown"
                }
            }
        end
        assert(req ~= nil)
        return req
    else
        local res = self.serve_d.request_sync(method, param, self.timeout, bufnr)
        if type(res) == "table" then
            return res
        elseif type(res) == "string" then
            return {
                err = {
                    code = nil,
                    message = res
                }
            }
        elseif type(res) == "nil" then
            return {
                err = {
                    code = nil,
                    message = "LSP client returned nil"
                }
            }
        else
            error("Unexpected response type `" .. type(res) .. "`: " .. vim.inspect(res))
        end
    end
end

---Send notification to the server
---@param method string
---@param param table?
---@return boolean
function ServeD:sendNotification(method, param)
    return self.serve_d.notify(method, param)
end

---Command to sort all user imports in a block at a given position in given code.
---Returns a list of changes to apply. (Replaces the whole block currently if
---anything changed, otherwise empty)
---@param param SortImportsParams
---@param bufnr integer?
---@return ErrorOr<TextEdit[]>
function ServeD:sortImports(param, bufnr)
    local request = "served/sortImports"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<TextEdit[]>
    return res
end

--- Implements the interfaces or abstract classes of a specified class/interface.
--- The given position must be on/inside the identifier of any subclass after
--- the colon (`:`) in a class definition.
---@param param ImplementMethodsParams
---@param bufnr integer?
---@return ErrorOr<TextEdit[]>
function ServeD:implementMethods(param, bufnr)
    local request = "served/implementMethods"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<TextEdit[]>
    return res
end

---Restarts all DCD servers started by this serve-d instance.
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:restartServer(bufnr)
    local request = "served/restartServer"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Kills all DCD servers started by this serve-d instance.
---@return boolean
function ServeD:killServer()
    local notification = "served/killServer"
    return self:sendNotification(notification)
end

---Manually triggers a DCD update either by compiling from source or downloading
---prebuilt binaries depending on the host system and serve-d. Excessively calls
---the `coded/logInstall` notification.
---@return boolean
function ServeD:updateDCD()
    local notification = "served/updateDCD"
    return self:sendNotification(notification)
end

---Returns an empty array if there is no active instance or if it doesn't have dub.
---Otherwise returns the names of available [configurations](https://dub.pm/package-format-json.html#configurations) in dub.
---@param bufnr integer?
---@return ErrorOr<string[]>
function ServeD:listConfigurations(bufnr)
    local request = "served/listConfigurations"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string[]>
    return res
end

---Sets the current dub configuration for building and other tools.
---@param param string
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:switchConfig(param, bufnr)
    local request = "served/switchConfig"
    local res = self:runRequest(request, { param }, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Returns the current dub configuration or null if there is no dub in the
---active instance.
---@param bufnr integer?
---@return ErrorOr<string>
function ServeD:getConfig(bufnr)
    local request = "served/getConfig"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string>
    return res
end

---Returns an empty array if there is no active instance or if it doesn't have dub.
---Otherwise returns the names of available architectures in dub. (e.g. x86 or x86_64)
---@param param ListArchTypesParams
---@param bufnr integer?
---@return ErrorOr<string[] | ArchTypeInfo[]>
function ServeD:listArchTypes(param, bufnr)
    local request = "served/listArchTypes"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<string[] | ArchTypeInfo[]>
    return res
end

---Sets the current architecture for building and other tools.
---@param param string
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:switchArchType(param, bufnr)
    local request = "served/switchArchType"
    local res = self:runRequest(request, { param }, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Returns the current dub architecture or null if there is no dub in the active
---instance.
---@param bufnr integer?
---@return ErrorOr<string>
function ServeD:getArchType(bufnr)
    local request = "served/getArchType"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string>
    return res
end

---Returns an empty array if there is no active instance or if it doesn't have dub.
---Otherwise returns the names of available [build types](https://dub.pm/package-format-json.html#build-types) in dub.
---@param bufnr integer?
---@return ErrorOr<string[]>
function ServeD:listBuildTypes(bufnr)
    local request = "served/listBuildTypes"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string[]>
    return res
end

---Sets the current dub build type for building and other tools.
---@param param string
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:switchBuildType(param, bufnr)
    local request = "served/switchBuildType"
    local res = self:runRequest(request, { param }, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Returns the current dub build type or null if there is no dub in the active instance.
---@param bufnr integer?
---@return ErrorOr<string>
function ServeD:getBuildType(bufnr)
    local request = "served/getBuildType"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string>
    return res
end

---Returns the name of the current compiler.
---@param bufnr integer?
---@return ErrorOr<string>
function ServeD:getCompiler(bufnr)
    local request = "served/getCompiler"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<string>
    return res
end

---Sets the current compiler to use in dub for building and other tools.
---@param param string
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:switchCompiler(param, bufnr)
    local request = "served/switchCompiler"
    local res = self:runRequest(request, { param }, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Parses the source code and returns code edits how to insert a given import
---into the code.
---@param param AddImportParams
---@param bufnr integer?
---@return ErrorOr<ImportModification>
function ServeD:addImport(param, bufnr)
    local request = "served/addImport"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<ImportModification>
    return res
end

---Refreshes the dub dependencies from the local filesystem. Triggers a
---`coded/updateDubTree` notification on success and updates imports in DCD.
---@param param UpdateImportsParams
---@param bufnr integer?
---@return ErrorOr<boolean>
function ServeD:updateImports(param, bufnr)
    local request = "served/updateImports"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<boolean>
    return res
end

---Lists the dependencies of a given dub package name. If no package name is
---given (empty string) then all dependencies of the current instance will be listed.
---@param param string
---@param bufnr integer?
---@return ErrorOr<DubDependency[]>
function ServeD:listDependencies(param, bufnr)
    local request = "served/listDependencies"
    local res = self:runRequest(request, { param }, bufnr, nil)
    ---@cast res ErrorOr<DubDependency[]>
    return res
end

---Returns a list of build tasks for all dub instances in the project.
---Currently each with Build, Run, Rebuild and Test commands.
---@param bufnr integer?
---@return ErrorOr<Task[]>
function ServeD:buildTasks(bufnr)
    local request = "served/buildTasks"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<Task[]>
    return res
end

---Starts a conversion of a dub.json/dub.sdl file to a given other format. Shows
---an error message in the UI if unsuccessful and triggers a
---`workspace/applyEdit` command when successful with the new content.
---@param param DubConvertRequest
---@return boolean
function ServeD:convertDubFormat(param)
    local notification = "served/convertDubFormat"
    return self:sendNotification(notification, param)
end

---Adds a dependency to the dub recipe file of the currently active instance
---(respecting indentation) and calls dub upgrade and updates imports afterwards.
---Writes changes to the file system.
---@param param InstallRequest
---@return boolean
function ServeD:installDependency(param)
    local notification = "served/installDependency"
    return self:sendNotification(notification, param)
end

---Changes a dependency in the dub recipe file of the currently active instance
---(respecting indentation) to the given version and calls dub upgrade and
---updates imports afterwards.
---Does nothing if the dependency wasn't found in the dub recipe.
---Writes changes to the file system.
---@param param UpdateRequest
---@return boolean
function ServeD:updateDependency(param)
    local notification = "served/updateDependency"
    return self:sendNotification(notification, param)
end

---Removes a dependency from the dub recipe file of the currently active
---instance and calls dub upgrade and updates imports afterwards.
---Writes changes to the file system.
---@param param UninstallRequest
---@return boolean
function ServeD:uninstallDependency(param)
    local notification = "served/uninstallDependency"
    return self:sendNotification(notification, param)
end

---Manually triggers DScanner linting on the given file. (respecting user configuration)
---@param param DocumentLinkParams
---@return boolean
function ServeD:doDscanner(param)
    local notification = "served/doDscanner"
    return self:sendNotification(notification, param)
end

---Searches for a given filename (optionally also with subfolders) and returns
---all locations in the project and all dependencies including standard library
---where this file exists.
---@param query string
---@param bufnr integer?
---@return ErrorOr<string[]>
function ServeD:searchFile(query, bufnr)
    local request = "served/searchFile"
    local res = self:runRequest(request, { query }, bufnr, nil)
    ---@cast res ErrorOr<string[]>
    return res
end

---Lists all files with a given module name in the project and all dependencies
---and standard library.
---@param module string
---@param bufnr integer?
---@return ErrorOr<string[]>
function ServeD:findFilesByModule(module, bufnr)
    local request = "served/findFilesByModule"
    local res = self:runRequest(request, { module }, bufnr, nil)
    ---@cast res ErrorOr<string[]>
    return res
end

---Returns the current D-Scanner configuration for a given URI.
---@param param DocumentLinkParams
---@param bufnr integer?
---@return ErrorOr<DScannerIniSection[]>
function ServeD:getDscannerConfig(param, bufnr)
    local request = "served/getDscannerConfig"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<DScannerIniSection[]>
    return res
end

---Returns dub information for the currently active project (dub project where last file
---was edited / opened / etc)
---@param bufnr integer?
---@return ErrorOr<DubConfig>
function ServeD:getActiveDubConfig(bufnr)
    local request = "served/getActiveDubConfig"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<DubConfig>
    return res
end

---Returns all profilegc.log entries parsed and combined.
---@param bufnr integer?
---@return ErrorOr<ProfileGCEntry[]>
function ServeD:getProfileGCEntries(bufnr)
    local request = "served/getProfileGCEntries"
    local res = self:runRequest(request, {}, bufnr, nil)
    ---@cast res ErrorOr<ProfileGCEntry[]>
    return res
end

---This notification triggers the use of alternate configuration notifications.
---Once this is received, the server will ignore `workspace/didConfigurationChange`
---notifications. This mechanisms exists to support some client/plugin combinations
---where the plugin needs more direct control over the configuration.
---@param param DidChangeConfigurationParams
---@return boolean
function ServeD:didChangeConfiguration(param)
    local notification = "served/didChangeConfiguration"
    return self:sendNotification(notification, param)
end

---Returns all profilegc.log entries parsed and combined.
---@param param ServedInfoParams
---@param bufnr integer?
---@return ErrorOr<ServedInfoResponse>
function ServeD:getInfo(param, bufnr)
    local request = "served/getInfo"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<ServedInfoResponse>
    return res
end

---Forces the load of projects, regardless of manyProjects limit or action
---configuration of the given file paths. Returns true if successful, false
---otherwise, for each item in the params array in order that was given in.
---@param param string[]
---@param bufnr integer?
---@return ErrorOr<boolean[]>
function ServeD:forceLoadProjects(param, bufnr)
    local request = "served/forceLoadProjects"
    local res = self:runRequest(request, param, bufnr, nil)
    ---@cast res ErrorOr<boolean[]>
    return res
end

---Tells the client to update a user or workspace setting. This is done for
---updating the dcdClientPath and dcdServerPath on installation.
---@param callback HandlerFor<UpdateSettingParams, nil>
function ServeD:onUpdateSerring(callback)
    local notification = "coded/updateSetting"
    self.serve_d.handlers[notification] = callback
end

---Instructs the client to log a message that has something to do with the
---installation routine of serve-d or dependencies.
---@param callback HandlerFor<string, nil>
function ServeD:onLogInstall(callback)
    local notification = "coded/logInstall"
    -- self.serve_d.handlers[notification] = function(err, res, ctx) return callback(err, res[1], ctx) end
    self.serve_d.handlers[notification] = callback
end

---Tells the client that dub has been loaded and the dependency tree can now be fetched.
---@param callback HandlerFor<nil, nil>
function ServeD:onInitDubTree(callback)
    local notification = "coded/initDubTree"
    self.serve_d.handlers[notification] = callback
end

---Tells the client that dub dependencies have been reloaded and should be redisplayed.
---@param callback HandlerFor<nil, nil>
function ServeD:onUpdateDubTree(callback)
    local notification = "coded/updateDubTree"
    self.serve_d.handlers[notification] = callback
end

---Tells the client when the active instance changed.
---@param callback HandlerFor<WorkspaceState, nil>
function ServeD:onChangedSelectedWorkspace(callback)
    local notification = "coded/changedSelectedWorkspace"
    self.serve_d.handlers[notification] = callback
end

---Tells the client that project loading was skipped for the given path(s).
---The client may then ask the user or query configuration if the paths should
---be loaded or skipped. When requesting to load projects, pass these roots as
---arguments to the reqeust `served/forceLoadProjects`. Otherwise, project
---loading is blocking and asks the client using a message box for each
---lazy-loaded project. IDE functionality is otherwise limited while these
---message boxes are open. This must be implemented if `--provide async-ask-load`
---is given in the command line, otherwise this is not called.
---@param callback HandlerFor<SkippedLoadsNotification, nil>
function ServeD:onSkippedLoads(callback)
    local notification = "coded/skippedLoads"
    self.serve_d.handlers[notification] = callback
end

---Instructs the client to download a file into a given output path using download UI.
---This must be implemented if `--provide http` is given in the command line,
---otherwise this is not called.
---@param callback HandlerFor<InteractiveDownload, boolean>
function ServeD:onInteractiveDownload(callback)
    local request = "coded/interactiveDownload"
    self.serve_d.handlers[request] = callback
end

return ServeD
