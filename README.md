[English](#english) | [日本語](#日本語) | [繁體中文](#繁體中文)

---

## English

# Ruby HTTP Error Statuses

**Interactive Demo Site:** https://yuandesu.github.io/dd-trace-ruby-http-error-statuses/

A minimal Ruby + Rack demo comparing three approaches to handling 4xx HTTP errors in Datadog APM and Error Tracking.

By default, the Datadog Ruby tracer only marks **5xx responses** as errors. This demo shows:

1. What happens without any configuration (default behavior)
2. How `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` makes 4xx responses appear as errors in APM Traces Explorer
3. How `span.set_error` enables full Error Tracking (Issues) by attaching `error.type`, `error.message`, and `error.stack`

### Key Difference

| | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` | `span.set_error` |
|---|---|---|
| Sets `span.status = 1` (error) | ✅ | ✅ |
| Sets `error.type` / `error.message` / `error.stack` | ❌ | ✅ |
| Visible in APM Traces Explorer as error | ✅ | ✅ |
| Creates Issues in Error Tracking | ❌ | ✅ |

### Services Comparison

| Service | Configuration | APM error | Error Tracking |
|---------|--------------|-----------|----------------|
| `http-status-before` | Default (nothing set) | ❌ | ❌ |
| `http-status-after` | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES=403,422,500-599` | ✅ | ❌ |
| `http-status-for-error-tracking` | `span.set_error` called in code | ✅ | ✅ |

### Prerequisites

- Docker & Docker Compose
- A Datadog account with APM enabled
- A valid Datadog API key

### Quick Start

**1. Clone the repository**

```bash
git clone https://github.com/yuandesu/ruby-http-error-statuses.git
cd ruby-http-error-statuses
```

**2. Create a `.env` file**

```bash
echo "DD_API_KEY=your_datadog_api_key_here" > .env
```

**3. Start all services**

```bash
docker compose up -d
```

| Container | Port | Description |
|-----------|------|-------------|
| `datadog-agent` | 8127 | Datadog Agent |
| `app-before` | 4001 | No error config (default) |
| `app-after` | 4002 | With `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` |
| `app-for-error-tracking` | 4003 | With `span.set_error` |

**4. Send test requests**

```bash
bash test.sh
```

**5. Check results in Datadog**

- [APM → Traces](https://app.datadoghq.com/apm/traces) — filter by `env:local`
  - `http-status-before`: 403/422 spans appear normal (no error highlight)
  - `http-status-after`: 403/422 spans appear in red, but "Missing error message and stack trace"
  - `http-status-for-error-tracking`: 403/422 spans appear in red with full error details

- [APM → Error Tracking](https://app.datadoghq.com/apm/error-tracking) — filter by `env:local`
  - Only `http-status-for-error-tracking` creates Issues

**6. Cleanup**

```bash
docker compose down
```

### Endpoints

| Path | HTTP Status |
|------|-------------|
| `/ok` | 200 |
| `/forbidden` | 403 |
| `/unprocessable` | 422 |

### Screenshots

**Traces list** — `http-status-before` shows 403/422 as normal; `http-status-after` shows them in red:

![Traces list](images/01_traces_list.png)

**Before: GET 422 span** — no error flag, treated as a normal response:

![Before 422](images/02_before_422.png)

**After: GET 422 span** — marked as error (`status=1`), but shows "Missing error message and stack trace" because `error.type` / `error.message` are not set:

![After 422](images/03_after_422.png)

**For Error Tracking: GET 422 span** — `span.set_error` sets both `span.status=1` and full error tags, showing complete error details:

![For Error Tracking span](images/04_for-error-tracking.png)

**Error Tracking — Issues list** — only `http-status-for-error-tracking` creates Issues, because it is the only service that sets `error.type` / `error.message` / `error.stack`:

![Error Tracking Issues](images/05_error_tracking.png)

### Reference

- [Datadog docs: DD_TRACE_HTTP_SERVER_ERROR_STATUSES](https://docs.datadoghq.com/tracing/trace_collection/library_config/)
- [Datadog docs: Use span attributes to track error spans](https://docs.datadoghq.com/tracing/error_tracking/#use-span-attributes-to-track-error-spans)
- [dd-trace-rb](https://github.com/DataDog/dd-trace-rb)

---

## 日本語

# Ruby HTTP エラーステータス

**インタラクティブデモサイト:** https://yuandesu.github.io/dd-trace-ruby-http-error-statuses/

Ruby + Rack で作った最小構成のデモです。4xx レスポンスを Datadog APM / Error Tracking でどう扱うかを、3 つのパターンで比較します。

Datadog Ruby トレーサーはデフォルトで **5xx レスポンスのみ**をエラーとしてマークします。このデモでは以下を確認できます。

1. 何も設定しない場合（デフォルト動作）
2. `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` を使って 4xx を APM Traces Explorer にエラーとして表示する方法
3. `span.set_error` を使って `error.type` / `error.message` / `error.stack` を付与し、Error Tracking（Issues）を有効にする方法

### 設定の違い

| | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` | `span.set_error` |
|---|---|---|
| `span.status = 1`（エラー）に設定 | ✅ | ✅ |
| `error.type` / `error.message` / `error.stack` を付与 | ❌ | ✅ |
| APM Traces Explorer にエラー表示 | ✅ | ✅ |
| Error Tracking に Issue 作成 | ❌ | ✅ |

### サービス比較

| サービス | 設定 | APM エラー | Error Tracking |
|---------|------|-----------|----------------|
| `http-status-before` | デフォルト（未設定） | ❌ | ❌ |
| `http-status-after` | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES=403,422,500-599` | ✅ | ❌ |
| `http-status-for-error-tracking` | コード内で `span.set_error` を呼び出す | ✅ | ✅ |

### 前提条件

- Docker & Docker Compose
- APM が有効な Datadog アカウント
- 有効な Datadog API キー

### クイックスタート

**1. リポジトリをクローン**

```bash
git clone https://github.com/yuandesu/ruby-http-error-statuses.git
cd ruby-http-error-statuses
```

**2. `.env` ファイルを作成**

```bash
echo "DD_API_KEY=your_datadog_api_key_here" > .env
```

**3. 全サービスを起動**

```bash
docker compose up -d
```

| コンテナ | ポート | 説明 |
|---------|--------|------|
| `datadog-agent` | 8127 | Datadog Agent |
| `app-before` | 4001 | エラー設定なし（デフォルト） |
| `app-after` | 4002 | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` あり |
| `app-for-error-tracking` | 4003 | `span.set_error` あり |

**4. テストリクエストを送信**

```bash
bash test.sh
```

**5. Datadog で確認**

- [APM → Traces](https://app.datadoghq.com/apm/traces) — `env:local` でフィルタ
  - `http-status-before`: 403/422 のスパンはエラー表示なし（グレー）
  - `http-status-after`: 403/422 のスパンが赤く表示されるが「Missing error message and stack trace」
  - `http-status-for-error-tracking`: 403/422 のスパンが赤く表示され、エラー詳細も確認できる

- [APM → Error Tracking](https://app.datadoghq.com/apm/error-tracking) — `env:local` でフィルタ
  - `http-status-for-error-tracking` のみ Issue が作成される

**6. 停止**

```bash
docker compose down
```

### エンドポイント

| パス | HTTP ステータス |
|------|----------------|
| `/ok` | 200 |
| `/forbidden` | 403 |
| `/unprocessable` | 422 |

### スクリーンショット

**トレース一覧** — `http-status-before` では 403/422 がエラー表示されず、`http-status-after` では赤く表示される:

![Traces list](images/01_traces_list.png)

**Before: GET 422 スパン** — エラーフラグなし、通常レスポンスとして扱われる:

![Before 422](images/02_before_422.png)

**After: GET 422 スパン** — `span.status=1` に設定されエラー表示されるが、`error.type` / `error.message` がないため「Missing error message and stack trace」と表示される:

![After 422](images/03_after_422.png)

**For Error Tracking: GET 422 スパン** — `span.set_error` により `span.status=1` とエラータグが同時にセットされ、エラーの全詳細が表示される:

![For Error Tracking span](images/04_for-error-tracking.png)

**Error Tracking — Issue 一覧** — `error.type` / `error.message` / `error.stack` を付与している `http-status-for-error-tracking` のみ Issue が作成される:

![Error Tracking Issues](images/05_error_tracking.png)

### 参考ドキュメント

- [Datadog docs: DD_TRACE_HTTP_SERVER_ERROR_STATUSES](https://docs.datadoghq.com/tracing/trace_collection/library_config/)
- [Datadog docs: Use span attributes to track error spans](https://docs.datadoghq.com/tracing/error_tracking/#use-span-attributes-to-track-error-spans)
- [dd-trace-rb](https://github.com/DataDog/dd-trace-rb)

---

## 繁體中文

# Ruby HTTP 錯誤狀態

**互動示範網站:** https://yuandesu.github.io/dd-trace-ruby-http-error-statuses/

這是一個最小化的 Ruby + Rack 示範，比較在 Datadog APM 和 Error Tracking 中處理 4xx HTTP 錯誤的三種方式。

Datadog Ruby tracer 預設只將 **5xx 回應**標記為錯誤。此示範展示：

1. 不進行任何設定時的情況（預設行為）
2. 使用 `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` 讓 4xx 回應在 APM Traces Explorer 中顯示為錯誤
3. 使用 `span.set_error` 附加 `error.type`、`error.message`、`error.stack`，啟用完整的 Error Tracking（Issues）

### 主要差異

| | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` | `span.set_error` |
|---|---|---|
| 設定 `span.status = 1`（錯誤） | ✅ | ✅ |
| 設定 `error.type` / `error.message` / `error.stack` | ❌ | ✅ |
| 在 APM Traces Explorer 中顯示為錯誤 | ✅ | ✅ |
| 在 Error Tracking 中建立 Issue | ❌ | ✅ |

### 服務比較

| 服務 | 設定 | APM 錯誤 | Error Tracking |
|---------|------|-----------|----------------|
| `http-status-before` | 預設（未設定） | ❌ | ❌ |
| `http-status-after` | `DD_TRACE_HTTP_SERVER_ERROR_STATUSES=403,422,500-599` | ✅ | ❌ |
| `http-status-for-error-tracking` | 程式碼中呼叫 `span.set_error` | ✅ | ✅ |

### 前置需求

- Docker & Docker Compose
- 已啟用 APM 的 Datadog 帳號
- 有效的 Datadog API 金鑰

### 快速啟動

**1. Clone 此 repository**

```bash
git clone https://github.com/yuandesu/ruby-http-error-statuses.git
cd ruby-http-error-statuses
```

**2. 建立 `.env` 檔案**

```bash
echo "DD_API_KEY=your_datadog_api_key_here" > .env
```

**3. 啟動所有服務**

```bash
docker compose up -d
```

| 容器 | Port | 說明 |
|------|------|------|
| `datadog-agent` | 8127 | Datadog Agent |
| `app-before` | 4001 | 無錯誤設定（預設） |
| `app-after` | 4002 | 使用 `DD_TRACE_HTTP_SERVER_ERROR_STATUSES` |
| `app-for-error-tracking` | 4003 | 使用 `span.set_error` |

**4. 發送測試請求**

```bash
bash test.sh
```

**5. 在 Datadog 中確認結果**

- [APM → Traces](https://app.datadoghq.com/apm/traces) — 以 `env:local` 篩選
  - `http-status-before`：403/422 spans 顯示正常（無錯誤標記）
  - `http-status-after`：403/422 spans 顯示為紅色，但出現「Missing error message and stack trace」
  - `http-status-for-error-tracking`：403/422 spans 顯示為紅色，並附有完整錯誤詳情

- [APM → Error Tracking](https://app.datadoghq.com/apm/error-tracking) — 以 `env:local` 篩選
  - 只有 `http-status-for-error-tracking` 會建立 Issues

**6. 清理環境**

```bash
docker compose down
```

### 端點

| 路徑 | HTTP 狀態碼 |
|------|------------|
| `/ok` | 200 |
| `/forbidden` | 403 |
| `/unprocessable` | 422 |

### 截圖

**Traces 列表** — `http-status-before` 的 403/422 顯示正常；`http-status-after` 的 403/422 顯示為紅色：

![Traces list](images/01_traces_list.png)

**Before: GET 422 span** — 無錯誤標記，視為正常回應：

![Before 422](images/02_before_422.png)

**After: GET 422 span** — 標記為錯誤（`status=1`），但因未設定 `error.type` / `error.message`，顯示「Missing error message and stack trace」：

![After 422](images/03_after_422.png)

**For Error Tracking: GET 422 span** — `span.set_error` 同時設定 `span.status=1` 與完整錯誤標籤，顯示完整錯誤詳情：

![For Error Tracking span](images/04_for-error-tracking.png)

**Error Tracking — Issue 列表** — 只有 `http-status-for-error-tracking` 建立了 Issues，因為它是唯一設定了 `error.type` / `error.message` / `error.stack` 的服務：

![Error Tracking Issues](images/05_error_tracking.png)

### 參考文件

- [Datadog docs: DD_TRACE_HTTP_SERVER_ERROR_STATUSES](https://docs.datadoghq.com/tracing/trace_collection/library_config/)
- [Datadog docs: Use span attributes to track error spans](https://docs.datadoghq.com/tracing/error_tracking/#use-span-attributes-to-track-error-spans)
- [dd-trace-rb](https://github.com/DataDog/dd-trace-rb)
