def solution(data, n):

    if len(data) <= 100:
        
        result = []
        numTracker = {}
    
        for num in data:
            if num in numTracker:
                numTracker[num] += 1
            else:
                numTracker[num] = 1

        for num in data:
            if isinstance(num, int) and numTracker[num] <= n and not(num in result):
                result.append(num)
            
        return result

result = solution([1, 2, 3, 4, 4, 909, 8797, "b", "123", 4], 2)
print(str(result))

list = [1, 2, 3, 4, 5]
print(list.count(1))

# nums = list(range(0, 100000)) + list(range(10, 100000))
# result = solution(nums, 1)
# print (str(result))