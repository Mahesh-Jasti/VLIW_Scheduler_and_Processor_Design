#include <bits/stdc++.h>
using namespace std;
typedef long long int ll;
typedef unsigned long long int ull;
#define mp make_pair
// GCD inbuilt func: __gcd(a,b)
// LCM formula: (a*b)/__gcd(a,b)

struct instr{
	string op;
	string dest;
	string src1;
	string src2;
	int imm;          // no loads -- instead directly put number into register // no stores as well for now
};

void print_instr(vector<instr> &v){
	cout << "----------INSTRUCTIONS----------\n";
	for(int i=0;i<v.size();i++){
		cout << v[i].op << " ";
		cout << v[i].dest << " ";
		if(v[i].src1!="NULL") cout << v[i].src1 << " ";
		if(v[i].src2!="NULL") cout << v[i].src2 << " ";
		if(v[i].imm!=-1) cout << v[i].imm << " ";
		cout << "\n";
	}
}

void print_graph(vector<pair<int,int>> graph[], int n){
	cout << "----------GRAPH----------\n";
	for(int i=0;i<n;i++){
		for(auto j:graph[i]){
			cout << "[" << j.first << ":" << j.second << "]";
		}
		cout << "\n";
	}
}

void print_degree(vector<int> &degree){
	cout << "----------DEGREE----------\n";
	for(int i=0;i<degree.size();i++){
		cout << "{" << i << ":" << degree[i] << "}";
	}
	cout << "\n";
}

void print_schedule(vector<vector<int>> &v){
	cout << "----------SCHEDULE----------\n";
	for(int i=0;i<v.size();i++){
		for(int j=0;j<v[i].size();j++){
			cout << "I" << v[i][j] << " ";
		}
		cout << "\n";
	}
}

void print_binary_instr(vector<string> &v){
	cout << "----------BINARY INSTRUCTIONS------------\n";
	for(int i=0;i<v.size();i++) cout << "I" << i << " " << v[i] << "\n";
}

void print_vliw_schedule(vector<string> &v){
	cout << "----------VLIW SCHEDULE-------------\n";
	for(auto i:v) cout << i << "\n";
}

void edge_degree_marking(vector<instr> &instructions, vector<pair<int,int>> graph[], vector<int> &degree){
	for(int i=0;i<instructions.size();i++){
		// true and output dependence
		for(int j=i+1;j<instructions.size();j++){
			if(instructions[j].src1==instructions[i].dest || instructions[j].src2==instructions[i].dest){
				graph[i].push_back({j,1});
				degree[j]++;
			}
			if(instructions[j].dest==instructions[i].dest){
				graph[i].push_back({j,1});
				degree[j]++;
				break;
			}
		}
		// anti dependence
		for(int j=i+1;j<instructions.size();j++){
			if(instructions[i].src1==instructions[j].dest){
				graph[i].push_back({j,0});
				degree[j]++;
				break;
			}
		}
		for(int j=i+1;j<instructions.size();j++){
			if(instructions[i].src2==instructions[j].dest){
				graph[i].push_back({j,0});
				degree[j]++;
				break;
			}
		}
	}
}

vector<int> topological_sort(vector<pair<int,int>> graph[], vector<int> &degree, int SLOTS){
	int n=degree.size();
	// anti dependance allowance
	set<int> ready_list;
	for(int i=0;i<n;i++){
		if(degree[i]==0){
			ready_list.insert(i);
			for(auto j:graph[i]){
				if(j.second==0 && degree[j.first]==1){
					degree[j.first]--;
					ready_list.insert(j.first);
				}
			}
		}
	}
	// scheduling
	vector<int> v;
	for(auto i:ready_list){
		if(v.size()==SLOTS) break;
		v.push_back(i);
		degree[i]--;
		for(auto j:graph[i]){
			if(!ready_list.count(j.first)) degree[j.first]--;   /// we might be subtracting the anti dependent instruction twice, hence the condition
		}
	}
	return v;
}

vector<string> instr_to_binary(vector<instr> &instructions){
	map<string,string> op_map={{"ADD","000"},{"MUL","001"},{"ADDI","010"},{"MOV","100"}};
	map<string,string> reg_map={{"R0","000"},{"R1","001"},{"R2","010"},{"R3","011"},{"R4","100"},{"R5","101"},{"R6","110"},{"R7","111"},{"NULL","000"}};
	vector<string> b_instr;
	for(int i=0;i<instructions.size();i++){
		string b_op=op_map[instructions[i].op];
		string b_dest=reg_map[instructions[i].dest];
		string b_src1=reg_map[instructions[i].src1];
		string b_src2=reg_map[instructions[i].src2];
		string b_imm="";
		if(instructions[i].imm!=1){
			int times=19;
			int x=instructions[i].imm;
			while(times--){
				if(x%2) b_imm+="1";
				else b_imm+="0";
				x/=2; 
			}
			reverse(b_imm.begin(),b_imm.end());
		}
		else b_imm="0000000000000000000";
		b_instr.push_back("1"+b_imm+b_src2+b_src1+b_dest+b_op);
	}
	return b_instr;
}

vector<string> vliw_schedule_binary(vector<string> &b_instr, vector<vector<int>> &schedule, int SLOTS){
	vector<string> vliw_schedule;
	for(int i=0;i<schedule.size();i++){
		string temp="128'b";
		for(int j=0;j<SLOTS-schedule[i].size();j++) temp+="00000000000000000000000000000000";
		for(int j=schedule[i].size()-1;j>-1;j--) temp+=b_instr[schedule[i][j]];
		vliw_schedule.push_back(temp);
	}
	return vliw_schedule;
}

int main(){
	ios::sync_with_stdio(false);
	cin.tie(NULL);
	// CODE goes here
	int SLOTS;
	cin >> SLOTS;
	// input
	vector<instr> instructions;
	while(1){
		string opcode;
		cin >> opcode;
		if(opcode=="ADD" || opcode=="MUL"){
			string d,s1,s2;
			cin >> d >> s1 >> s2;
			instructions.push_back({opcode,d,s1,s2,-1});
		}
		else if(opcode=="ADDI"){
			string d,s1;
			int im;
			cin >> d >> s1 >> im;
			instructions.push_back({opcode,d,s1,"NULL",im});
		}
		else if(opcode=="MOV"){
			string d;
			int im;
			cin >> d >> im;
			instructions.push_back({opcode,d,"NULL","NULL",im});
		}
		else if(opcode=="EXIT") break;
	}

	print_instr(instructions);

	// graph 
	vector<pair<int,int>> graph[instructions.size()];
	vector<int> degree(instructions.size(),0);
	
	edge_degree_marking(instructions,graph,degree);

	print_graph(graph,instructions.size());

	print_degree(degree);

	vector<vector<int>> schedule;
	bool flag=true;
	while(flag){
		flag=false;
		for(int i=0;i<degree.size();i++){
			if(degree[i]>=0) flag=true;
		}
		if(flag){
			vector<int> v=topological_sort(graph,degree,SLOTS);
			schedule.push_back(v);
		}
	}

	print_schedule(schedule);

	vector<string> binary_instr=instr_to_binary(instructions);

	print_binary_instr(binary_instr);

	vector<string> vliw_schedule=vliw_schedule_binary(binary_instr,schedule,SLOTS);

	print_vliw_schedule(vliw_schedule);

	return 0;
}

/* SAMPLE INPUT
6
MOV R2 0
MOV R3 1
MOV R4 2
ADDI R1 R2 1
MUL R2 R3 R3
MUL R5 R1 R3
ADDI R5 R5 1
ADD R6 R2 R4
EXIT
*/

