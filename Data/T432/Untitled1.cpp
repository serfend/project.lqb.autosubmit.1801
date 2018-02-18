#include <cstdio>
#include <iostream>
#include <cstring>
#include <string>
#include <queue>
#define fill(x) memset(x, -1, sizeof(x))
#define N 200007
#define min(x, y) ((x) < (y) ? (x) : (y))
#define INF 0x7f7f7f7f
#define rep(i, a, b)	for (int i= a; i <= b; i++)
#define eg(i, x)	for (int i = ls[x]; i; i = e[i].next)
using namespace std;
struct edge
{
	int x, to, next, flow;
}e[N];
int n, m, S = 0, T, d[N], ls[N], cnt, ans;

void add(int x, int y, int z)
{
	e[++cnt].to = y;
	e[cnt].flow = z;
	e[cnt].next = ls[x];
	ls[x] = cnt;
	
	e[++cnt].to = x;
	e[cnt].flow = 0;
	e[cnt].next = ls[y];
	ls[y] = cnt;
}

bool bfs()
{
	fill(d);
	d[0] = 1;
	queue<int> q;
	q.push(0);
	while (!q.empty())
	{
		int x = q.front(); q.pop();
		eg(i, x)
			if (d[e[i].to] < 0 && e[i].flow > 0)
				d[e[i].to] = d[x] + 1, q.push(e[i].to);
	}
	if (d[T] > 0)	return 1;
	return 0;
}

int dfs(int x, int mx)
{
	int a;
	if (x == T)	return mx;
	eg(i, x)
	{
		if (e[i].flow > 0 && d[e[i].to] == d[x] + 1 && (a = dfs(e[i].to, min(mx, e[i].flow))))
		{
			e[i].flow -= a;
			e[i ^ 1].flow += a;
			return a;
		}
	}
	return 0;
}

int main()
{
	scanf("%d%d", &n, &m);
	T = m + 10;
	cnt=1;
	rep(i, 1, n)
		add(S, i, 1);
	rep(i, n + 1, m)
		add(i, T, 1);
	int x, y;
	scanf("%d%d", &x, &y);
	while (x != -1)
	{
		add(x, y, INF);
		scanf("%d%d", &x, &y);
	}
	int res;
	while (bfs())
	{
		while (res = dfs(0, INF))	ans += res;
	}
	printf("%d\n", ans);
}
