local PLUGIN = PLUGIN

-- Client-side storage for obstacle course data
PLUGIN.obstacleCoursesClient = PLUGIN.obstacleCoursesClient or {}

-- Receive course data updates from server
net.Receive("expObstacleCourseUpdate", function()
	local courseID = net.ReadString()
	local courseData = net.ReadTable()

	-- Store the networked data
	PLUGIN.obstacleCoursesClient[courseID] = courseData
end)
