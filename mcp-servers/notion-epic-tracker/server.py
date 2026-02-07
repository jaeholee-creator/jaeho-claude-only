"""Notion Epic Tracker MCP Server — AX Epics / Task Backlog 연동."""

import os
from datetime import datetime, timezone, timedelta
from typing import Any, Optional

from mcp.server.fastmcp import FastMCP
from notion_client import Client as NotionClient

NOTION_TOKEN = os.environ.get("NOTION_TOKEN", "")

EPIC_DB_ID = "2ed686b4-9b3b-8122-878f-e7ccb772321f"
TASK_DB_ID = "abbfbcff-91ce-4f5b-b182-241f77bba9db"
EPIC_DS_ID = "2ed686b4-9b3b-8164-a922-000b2ed41878"
TASK_DS_ID = "bb11b501-847c-4621-9bf1-44387c93cb66"

KST = timezone(timedelta(hours=9))


def _get_notion() -> NotionClient:
    if not NOTION_TOKEN:
        raise RuntimeError("NOTION_TOKEN 환경변수가 설정되지 않았습니다.")
    return NotionClient(auth=NOTION_TOKEN)


def _extract_title(properties: dict, field_name: str) -> str:
    title_parts = properties.get(field_name, {}).get("title", [])
    return title_parts[0].get("plain_text", "") if title_parts else ""


def _extract_select(properties: dict, field_name: str) -> str:
    sel = properties.get(field_name, {}).get("select")
    return sel.get("name", "") if sel else ""


def _extract_date(properties: dict, field_name: str) -> str:
    date_val = properties.get(field_name, {}).get("date")
    return date_val.get("start", "") if date_val else ""


def _extract_rollup_number(properties: dict, field_name: str) -> Any:
    return properties.get(field_name, {}).get("rollup", {}).get("number")


def _query_ds(notion: NotionClient, ds_id: str, **kwargs) -> dict:
    return notion.data_sources.query(data_source_id=ds_id, **kwargs)


def _find_epic_by_name(notion: NotionClient, epic_name: str) -> Optional[dict]:
    result = _query_ds(
        notion, EPIC_DS_ID,
        filter={"property": "Epic Name", "title": {"equals": epic_name}},
        page_size=1,
    )
    results = result.get("results", [])
    return results[0] if results else None


def _find_task_by_name(
    notion: NotionClient, task_name: str, epic_id: Optional[str] = None
) -> Optional[dict]:
    if epic_id:
        filter_cond: dict = {
            "and": [
                {"property": "업무명", "title": {"equals": task_name}},
                {"property": "Epic", "relation": {"contains": epic_id}},
            ]
        }
    else:
        filter_cond = {"property": "업무명", "title": {"equals": task_name}}

    result = _query_ds(notion, TASK_DS_ID, filter=filter_cond, page_size=1)
    results = result.get("results", [])
    return results[0] if results else None


mcp = FastMCP(
    "Notion Epic Tracker",
    instructions=(
        "Notion 기반 Epic/Task 관리 도구입니다. "
        "AX 팀의 프로젝트(Epic)와 업무(Task)를 조회·생성·업데이트할 수 있습니다. "
        "작업 세션 로그를 기록하여 진척도를 추적합니다."
    ),
)


@mcp.tool()
def list_epics(status_filter: str = "") -> str:
    """활성 Epic 목록을 조회합니다.

    Args:
        status_filter: 상태 필터 ("Planning", "In Progress", "Done"). 빈 문자열이면 전체 조회.
    """
    notion = _get_notion()

    query_args: dict = {"page_size": 50}
    if status_filter:
        query_args["filter"] = {
            "property": "Status",
            "select": {"equals": status_filter},
        }

    result = _query_ds(notion, EPIC_DS_ID, **query_args)
    epics = []
    for page in result.get("results", []):
        props = page["properties"]
        name = _extract_title(props, "Epic Name")
        status = _extract_select(props, "Status")
        task_count = _extract_rollup_number(props, "Task Count")
        progress = _extract_rollup_number(props, "Progress")
        start = _extract_date(props, "Start Date")
        target = _extract_date(props, "Target Date")
        progress_pct = f"{int(progress * 100)}%" if progress is not None else "N/A"

        epics.append(
            f"• {name}\n"
            f"  Status: {status or 'N/A'} | Tasks: {task_count or 0} | "
            f"Progress: {progress_pct}\n"
            f"  기간: {start or '미정'} → {target or '미정'}"
        )

    if not epics:
        return "조회된 Epic이 없습니다."

    header = f"📋 AX Epics ({len(epics)}개)"
    if status_filter:
        header += f" [필터: {status_filter}]"
    return header + "\n\n" + "\n\n".join(epics)


@mcp.tool()
def list_tasks(epic_name: str, status_filter: str = "") -> str:
    """특정 Epic의 Task 목록을 조회합니다.

    Args:
        epic_name: Epic 이름 (정확히 일치). 빈 문자열이면 전체 Task 조회.
        status_filter: 현재 상태 필터 (예: "In Progress", "Done"). 빈 문자열이면 전체.
    """
    notion = _get_notion()
    filters = []

    if epic_name:
        epic_page = _find_epic_by_name(notion, epic_name)
        if not epic_page:
            return f"❌ Epic '{epic_name}'을(를) 찾을 수 없습니다."
        epic_id = epic_page["id"]
        filters.append({"property": "Epic", "relation": {"contains": epic_id}})

    if status_filter:
        filters.append({"property": "현재 상태", "select": {"equals": status_filter}})

    query_args: dict = {"page_size": 100}
    if len(filters) == 1:
        query_args["filter"] = filters[0]
    elif len(filters) > 1:
        query_args["filter"] = {"and": filters}

    result = _query_ds(notion, TASK_DS_ID, **query_args)
    tasks = []
    for page in result.get("results", []):
        props = page["properties"]
        name = _extract_title(props, "업무명")
        status = _extract_select(props, "현재 상태")
        priority = _extract_select(props, "Priority")
        completed = props.get("Completed", {}).get("checkbox", False)
        source = _extract_select(props, "Source")
        task_type = _extract_select(props, "Type")
        check = "✅" if completed else "⬜"
        pri_badge = f"[{priority}]" if priority else ""

        tasks.append(
            f"  {check} {pri_badge} {name}\n"
            f"     상태: {status or 'N/A'} | Source: {source or 'N/A'} | Type: {task_type or 'N/A'}"
        )

    if not tasks:
        label = f"Epic '{epic_name}'" if epic_name else "전체"
        return f"조회된 Task가 없습니다 ({label})."

    total = len(tasks)
    done_count = sum(
        1
        for p in result["results"]
        if _extract_select(p["properties"], "현재 상태") in ("Done", "Completed")
    )
    header = f"📝 Tasks for '{epic_name}' ({done_count}/{total} 완료)"
    if status_filter:
        header += f" [필터: {status_filter}]"
    return header + "\n\n" + "\n".join(tasks)


@mcp.tool()
def create_task(
    epic_name: str,
    task_name: str,
    task_type: str = "Feature",
    priority: str = "MEDIUM",
    source: str = "Internal",
) -> str:
    """새 Task를 생성하고 Epic에 연결합니다.

    Args:
        epic_name: 연결할 Epic 이름.
        task_name: 새 Task 이름.
        task_type: Task 유형 ("Feature", "Maintenance", "Research", "Bug"). 기본값 "Feature".
        priority: 우선순위 ("HIGH", "MEDIUM", "LOW"). 기본값 "MEDIUM".
        source: 출처 ("Internal", "External"). 기본값 "Internal".
    """
    notion = _get_notion()

    epic_page = _find_epic_by_name(notion, epic_name)
    if not epic_page:
        return f"❌ Epic '{epic_name}'을(를) 찾을 수 없습니다."
    epic_id = epic_page["id"]

    properties: dict = {
        "업무명": {"title": [{"text": {"content": task_name}}]},
        "Epic": {"relation": [{"id": epic_id}]},
        "현재 상태": {"select": {"name": "🆕 신규"}},
        "Source": {"select": {"name": source}},
    }
    if task_type:
        properties["Type"] = {"select": {"name": task_type}}
    if priority:
        properties["Priority"] = {"select": {"name": priority}}

    new_page = notion.pages.create(
        parent={"database_id": TASK_DB_ID},
        properties=properties,
    )

    url = new_page.get("url", "")
    return (
        f"✅ Task 생성 완료!\n"
        f"  이름: {task_name}\n"
        f"  Epic: {epic_name}\n"
        f"  상태: 🆕 신규 | 유형: {task_type} | 우선순위: {priority}\n"
        f"  URL: {url}"
    )


@mcp.tool()
def complete_task(epic_name: str, task_name: str) -> str:
    """Task를 완료 처리합니다. (현재 상태 → Done, Completed 체크)

    Args:
        epic_name: Epic 이름.
        task_name: 완료할 Task 이름.
    """
    notion = _get_notion()

    epic_page = _find_epic_by_name(notion, epic_name)
    epic_id = epic_page["id"] if epic_page else None

    task_page = _find_task_by_name(notion, task_name, epic_id)
    if not task_page:
        return f"❌ Task '{task_name}'을(를) 찾을 수 없습니다."

    notion.pages.update(
        page_id=task_page["id"],
        properties={
            "현재 상태": {"select": {"name": "Done"}},
            "Completed": {"checkbox": True},
        },
    )
    return f"✅ Task 완료 처리됨: {task_name}\n  상태: Done | Completed: ✓"


@mcp.tool()
def log_session(
    epic_name: str,
    summary: str,
    tasks_done: str = "",
) -> str:
    """작업 세션 로그를 Epic 페이지에 기록합니다.

    Args:
        epic_name: Epic 이름.
        summary: 오늘 작업 요약 (무엇을 했는지, 결과물 등).
        tasks_done: 완료한 Task 이름들 (쉼표로 구분). 빈 문자열이면 Task 상태 변경 없음.
    """
    notion = _get_notion()

    epic_page = _find_epic_by_name(notion, epic_name)
    if not epic_page:
        return f"❌ Epic '{epic_name}'을(를) 찾을 수 없습니다."
    epic_id = epic_page["id"]

    completed_tasks: list[str] = []
    if tasks_done:
        for tname in (t.strip() for t in tasks_done.split(",") if t.strip()):
            task_page = _find_task_by_name(notion, tname, epic_id)
            if task_page:
                notion.pages.update(
                    page_id=task_page["id"],
                    properties={
                        "현재 상태": {"select": {"name": "Done"}},
                        "Completed": {"checkbox": True},
                    },
                )
                completed_tasks.append(tname)

    now = datetime.now(KST)
    timestamp = now.strftime("%Y-%m-%d %H:%M")

    blocks: list[dict] = [
        {"object": "block", "type": "divider", "divider": {}},
        {
            "object": "block",
            "type": "heading_3",
            "heading_3": {
                "rich_text": [
                    {"type": "text", "text": {"content": f"📝 Session Log — {timestamp}"}}
                ]
            },
        },
        {
            "object": "block",
            "type": "paragraph",
            "paragraph": {
                "rich_text": [{"type": "text", "text": {"content": summary}}]
            },
        },
    ]

    if completed_tasks:
        blocks.append({
            "object": "block",
            "type": "paragraph",
            "paragraph": {
                "rich_text": [{
                    "type": "text",
                    "text": {"content": f"✅ 완료: {', '.join(completed_tasks)}"},
                    "annotations": {"bold": True},
                }]
            },
        })

    notion.blocks.children.append(block_id=epic_id, children=blocks)

    msg = f"📝 세션 로그 기록 완료!\n  Epic: {epic_name}\n  시간: {timestamp}\n  요약: {summary}"
    if completed_tasks:
        msg += f"\n  완료 Task: {', '.join(completed_tasks)}"
    return msg


@mcp.tool()
def update_dashboard(epic_name: str) -> str:
    """Epic 대시보드 요약을 조회합니다. (Task 통계, 진행률 등)

    Args:
        epic_name: Epic 이름.
    """
    notion = _get_notion()

    epic_page = _find_epic_by_name(notion, epic_name)
    if not epic_page:
        return f"❌ Epic '{epic_name}'을(를) 찾을 수 없습니다."

    epic_id = epic_page["id"]
    props = epic_page["properties"]
    status = _extract_select(props, "Status")
    task_count = _extract_rollup_number(props, "Task Count") or 0
    progress = _extract_rollup_number(props, "Progress")
    start = _extract_date(props, "Start Date")
    target = _extract_date(props, "Target Date")

    task_result = _query_ds(
        notion, TASK_DS_ID,
        filter={"property": "Epic", "relation": {"contains": epic_id}},
        page_size=100,
    )

    status_counts: dict[str, int] = {}
    for page in task_result.get("results", []):
        t_status = _extract_select(page["properties"], "현재 상태") or "없음"
        status_counts[t_status] = status_counts.get(t_status, 0) + 1

    total = len(task_result.get("results", []))
    done_count = status_counts.get("Done", 0) + status_counts.get("Completed", 0)
    in_progress = status_counts.get("In Progress", 0)
    blocked = status_counts.get("Blocked", 0)
    progress_pct = f"{int(progress * 100)}%" if progress is not None else "N/A"

    lines = [
        f"📊 Dashboard: {epic_name}",
        f"{'=' * 40}",
        f"상태: {status}",
        f"기간: {start or '미정'} → {target or '미정'}",
        "",
        f"📈 진행률: {progress_pct}",
        f"  전체 Task: {total}",
        f"  완료: {done_count}",
        f"  진행 중: {in_progress}",
        f"  차단됨: {blocked}",
        f"  기타: {total - done_count - in_progress - blocked}",
        "",
        "📋 상태별 분포:",
    ]
    for s, c in sorted(status_counts.items()):
        lines.append(f"  {s}: {'█' * c} ({c})")

    return "\n".join(lines)


def main():
    mcp.run()


if __name__ == "__main__":
    main()
