.data
coefficientMatrix: .float 1,1.5,3,1,-3,2  #(3*2)
Matrix_1: .float 1,2       #(2*1)
Matrix_2:.space 16
Matrix_3:.float 24          #内置的transpose的地址

.text     
     main:
       
     li $a0, 3                        #假设长
     li $a1, 2                         #假设宽
     la $a2,coefficientMatrix
     la $a3,Matrix_1
     la $t1,Matrix_2                   #新的生成的
     la $t2,Matrix_3                   #内置的transpose matrix的地址
     jal Multiply_matrix 
    #stop the program
    li $v0,10
    syscall

       
          # 这个是处理m*n (*n*1)的矩阵乘法
          #应该先transpose一下，然后在加     [1 2 3            
                                          #  4 5 6        
                                          #  7 8 9]                                          
         #a0: 矩阵的长
         #a1: 矩阵的宽
         #a2: 矩阵的地址
         #a3: 行列式的地址
         #t1: 新的生成的地址
         #t2: 内置的transpose matrix的地址
    Multiply_matrix:
         #保存地址
         addi $sp,$sp, -32
         sw $ra, 0($sp)
         sw $s0, 4($sp)
         sw $a0, 8($sp)
         sw $s1, 12($sp)
         sw $s2, 16($sp)
         sw $s3, 20($sp)
         sw $s4, 24($sp)
         move $s0,$a0  #矩阵的行的个数
         move $s1,$a1  #矩阵的列的个数
         move $s2,$a2  #矩阵的地址
         move $s3,$a3  #行列式的地址
         move $s4,$t1  #新的生成的地址
         # Save registers
         
          li $t2,0
      outer_multiply_loop2:
        bge $t2, $s0, end_multiply_outer2  # end outer loop if i>=16
        la $s3, Matrix_1 	     # Reset address of b_Matrix at the beginning of each outer loop iteration	
        move $t3, $zero         # set inner loop index j = zero
        #move $t4, $zero         # Accumulator for sum

       inner_multiply_loop2:
        bge $t3, $s1, end_multiply_inner2  # end inner loop     列的个数
        sll $t5,$t3, 2          # 4j
    
        #add $t6, $s2, $t5       # get the base of original 
        lwc1 $f0, 0($s2)         # get the element from base( coefficient)
        lwc1 $f1, 0($s3)         # get the element from base( b )
        mul.s $f2, $f0, $f1      #result
        add.s $f4, $f4, $f2      # accumulate the sum
    
        addi $t3, $t3, 1        # update the inner loop j
        addi $s2, $s2, 4        #update the original matrix
        addi $s3,$s3,4         #move to next position(address) b matrix 
        j inner_multiply_loop2
    
       end_multiply_inner2:
        swc1 $f4, 0($s4)        # Store sum in result matrix
        mtc1 $zero, $f4        #重置为0
        addi $s4, $s4, 4       # Move to next position(address) in result matrix
        #跳到下一行（列的个数*4）
        #mul $t8,$s1,4
        #add $s2,$s2,$t8
        addi $t2, $t2, 1        # increment outer loop index
       j outer_multiply_loop2           # Jump to outer loop

      end_multiply_outer2:
       jal Print_coefficient_Heap_Index     # Call print_array function
    
       # Restore registers
       lw $ra, 0($sp)
       lw $s0, 4($sp)
       lw $a0, 8($sp)
       lw $s1, 12($sp)
       lw $s2, 16($sp)
       lw $s3, 20($sp)
       lw $s4, 24($sp)
       lw $s5, 28($sp) 
       addi $sp, $sp, 32       # Restore stack pointer
       jr $ra                  # Return to caller
       
       
Print_coefficient_Heap_Index:
    addi $sp, $sp, -4     
    sw $ra, 0($sp)          

    la $t0,Matrix_2
    li $t1, 3          
     

print_coefficient_loop:
    beqz $t1, end_coefficient_print    
    #lw $t4,0($t0) 
    #move $a0,$t4
    lwc1 $f12, 0($t0)       
    cvt.w.s $f12, $f12      #change to integer 
    mfc1 $a0, $f12         
    li $v0, 1              # print int
    syscall 
    li $a0, ','             # 设置要打印的字符为逗号
    li $v0, 11              # 系统调用号为 11（打印字符）
    syscall               

    addi $t0, $t0, 4        # next number 
    addi $t1, $t1, -1       
    j print_coefficient_loop   
   end_coefficient_print:
    lw $ra, 0($sp)         
    addi $sp, $sp, 4      
    jr $ra 