

int main() {
	int a=0;
	int b=0;
	int c=0;

	for(int i=0; i<3; i++){
		a++;
		b++;
		c = c + a*b;
	}

	*(volatile unsigned int*)(0x200C) = c;
    return 0;
}

	
