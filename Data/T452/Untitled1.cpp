#include <iostream>
#include <queue>
#include <string.h>
using namespace std;
struct fruit{
	string name;
	int price;
//	friend bool operator <(const fruit &f1,const fruit &f2){
//		return f1.price>f2.price;
//	}
	bool operator ()(const fruit &f1,const fruit &f2){
		return f1.price>f2.price;
	}
}; 
priority_queue<fruit>q;
int main(){
	fruit f1,f2,f3;
	f1.name="梨子";
	f1.price=1;
	f2.name="果子";
	f2.price=3;
	f3.name="树子";
	f3.price=2;
	q.push(f1);
	q.push(f2);
	q.push(f3);
//	priority_queue<fruit>::iteritor it=q.
	while(!q.empty()){
		printf("%s:\t%d\n",q.top().name.c_str(),q.top().price);
		q.pop();
	}
	return 0;
}
