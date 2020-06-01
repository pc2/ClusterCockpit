<?php
/*
 *  This file is part of ClusterCockpit.
 *
 *  Copyright (c) 2018 Jan Eitzinger
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is furnished
 *  to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

namespace App\Controller\API;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Doctrine\ORM\EntityManagerInterface;
use FOS\RestBundle\View\View;
use App\Entity\Job;
use App\Entity\JobTag;
use App\Entity\Cluster;
use App\Entity\User;
use App\Entity\Node;
use App\Entity\Project;
use FOS\RestBundle\Controller\AbstractFOSRestController;
use FOS\RestBundle\Request\ParamFetcher;
use FOS\RestBundle\Controller\Annotations\QueryParam;

class JobsController extends AbstractFOSRestController
{
    public function postJobsAction(Request $request)
    {
	$action = $request->request->get('action');
        $jobId = $request->request->get('job_id');
	$userId = $request->request->get('user_id');
        $clusterId = $request->request->get('cluster_id');
	
	$startTime = $request->request->get('start_time');
        $nodes = $request->request->get('nodes');
        $jobScript = $request->request->get('job_script');
	$tagname = $request->request->get('tagname');
	$tagtype = $request->request->get('tagtype');
	$problem = $request->request->get('problem');
	$job_rep = $this->getDoctrine()->getRepository(Job::class);
	
	$view = new View();
	if ($action == "startjob" ){
		$user_rep = $this->getDoctrine()->getRepository(User::class);
		$node_rep = $this->getDoctrine()->getRepository(Node::class);
		$cluster_rep = $this->getDoctrine()->getRepository(Cluster::class);

		$job = $job_rep->findOneByJobId($jobId);
		if ($job) {
			#throw new HttpException(400, "Job already exists ".$jobId);


		}else{
			$job =  new Job;
			$job->setJobId($jobId);
		}

		$job->setStartTime($startTime);

		#$user = $user_rep->findOneByUserId($userId);
		$user = $user_rep->findOneByUsername($userId);
		if (empty($user)) {
		    throw new HttpException(400, "No such user ID: ".$userId);
		}
		$job->setUser($user);

		$cluster = $cluster_rep->findOneByName($clusterId);
		if (empty($cluster)) {
		    throw new HttpException(400, "No such cluster ".$clusterId);
		}
		$job->setCluster($cluster);

		foreach ( $nodes as $nodeId  ){
		    $node = $node_rep->findOneByNodeId($nodeId);

		    if (empty($node)) {
			throw new HttpException(400, "No such node ".$nodeId);
		    }
		    $job->addNode($node);
		}

		if (! empty($jobScript) ) {
		    $job->setJobScript($jobScript);
		}

		$job->setNumNodes(count($nodes));
		$job->setOutputRecommendations("no"); 

		$job->severity = 0;
		$job->isRunning = True;
		$job->isCached = False;
		$job->duration=600;
		$job->memBwAvg = 0;
		$job->memUsedAvg = 0;
		$job->flopsAnyAvg = 0;
		$job->trafficTotalLustreAvg = 0;
		$job->trafficTotalIbAvg = 0;

		$em = $this->getDoctrine()->getManager();
		$em->persist($job);
		$em->flush();
		
		$view->setStatusCode(200);
		$view->setData($job->getId());
	}elseif($action == "stopjob"){
		$stop_time = $request->request->get('stop_time');
		$job = $job_rep->findOneByJobId($jobId);

		if (empty($job)) {
		    throw new HttpException(400, "No such running job: $id");
		}

		$em = $this->getDoctrine()->getManager();
		#$id->getNodes()->clear();
		$job->setStopTime($stop_time); 
		$job->setIsRunning(false); 
		#$em->remove($id);
		$em->flush();

		$view = new View();
		$view->setStatusCode(200);
		$view->setData("SUCCESS");
	}elseif($action == "getstarttime"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getStartTime());
	}elseif($action == "getstoptime"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getStopTime());
	}elseif($action == "getnodes"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getNodes());
	}elseif($action == "getproblems"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getProblems());
	}elseif($action == "setnodes"){
		$job = $job_rep->findOneByJobId($jobId);
		if ($job) {
			$node_rep = $this->getDoctrine()->getRepository(Node::class);
			foreach ( $nodes as $nodeId  ){
			    $node = $node_rep->findOneByNodeId($nodeId);

			    if (empty($node)) {
				throw new HttpException(400, "No such node ".$nodeId);
			    }
			    $job->addNode($node);
			}
			$job->setNumNodes(count($nodes));
			$em = $this->getDoctrine()->getManager();
			$em->persist($job);
			$em->flush();
			$view->setData("SUCCESS");
		}
		$view->setStatusCode(200);
	}elseif($action == "addtag"){
		$job = $job_rep->findOneByJobId($jobId);
		
		$repository = $this->getDoctrine()->getRepository(\App\Entity\JobTag::class);

		/* check if tag already exists */
		$jobTag = $repository->findOneByName($tagname);

		/* add tag if not yet existing */
        	$em = $this->getDoctrine()->getManager();
		if (empty($jobTag)) {
		    $jobTag = new JobTag;
		    $jobTag->setName($tagname);
		    $jobTag->setType($tagtype);
		    $em->persist($jobTag);
		}

		/* add tag to job */
		if (!empty($job)) {
		    $jobTag->addJob($job);
		    $em->persist($job);
		    $em->flush();
		}
		$view->setData($job->getId());
		$view->setStatusCode(200);
	}elseif($action == "gettags"){
		$job = $job_rep->findOneByJobId($jobId);
		
		if (!empty($job)) {
			$repository = $this->getDoctrine()->getRepository(\App\Entity\JobTag::class);

			$taglist=array();
			$tags=$job->getTags();
			foreach ( $tags as $tag  ){
				if ($tag->getType()==$tagtype){
					array_push($taglist,$tag->getName());
				}
			}

			$view->setData($taglist);
			$view->setStatusCode(200);
		}else{
			$view->setStatusCode(500);
		}
	}elseif($action == "removetagsoftype"){
		$job = $job_rep->findOneByJobId($jobId);
		
		if (!empty($job)) {
			$repository = $this->getDoctrine()->getRepository(\App\Entity\JobTag::class);

			$tags=$job->getTags();
			foreach ( $tags as $tag  ){
				if ($tag->getType()==$tagtype){
					$tag->removeJob($job);
				}
			}

			$em = $this->getDoctrine()->getManager();
			$em->persist($job);
			$em->flush();
			$view->setData($job->getId());
			$view->setStatusCode(200);
		}else{
			$view->setStatusCode(500);
		}
	}elseif($action == "addproblem"){
		$job = $job_rep->findOneByJobId($jobId);
		
		$repository = $this->getDoctrine()->getRepository(\App\Entity\JobTag::class);

		/* add tag to job */
		if (!empty($job)) {
		    $job->addProblem($problem);
		    $em = $this->getDoctrine()->getManager();
		    $em->persist($job);
		    $em->flush();
		}
		$view->setData($job->getId());
		$view->setStatusCode(200);
	}elseif($action == "clearproblems"){
		$job = $job_rep->findOneByJobId($jobId);
		
		$repository = $this->getDoctrine()->getRepository(\App\Entity\JobTag::class);

		/* add tag to job */
		if (!empty($job)) {
		    $job->clearProblems();
		    $em = $this->getDoctrine()->getManager();
		    $em->persist($job);
		    $em->flush();
		}
		$view->setData($job->getId());
		$view->setStatusCode(200);
	}elseif($action == "getjobs"){
		$jobs = $job_rep->findRunningJobs();
		$stack = array();
		foreach ( $jobs as $job  ){
			array_push($stack, $job->getJobId());
		}

		$view->setStatusCode(200);
		$view->setData(json_encode($stack));
	}elseif($action == "getalljobs"){
		$jobs = $job_rep->findAllJobs();
		$stack = array();
		foreach ( $jobs as $job  ){
			array_push($stack, $job->getJobId());
		}

		$view->setStatusCode(200);
		$view->setData(json_encode($stack));
	}elseif($action == "getjobswithoutupdate"){
		$jobs = $job_rep->findRunningJobs();
		$stack = array();
		foreach ( $jobs as $job  ){
			if($job->getlastupdate()==0){
				array_push($stack, $job->getJobId());
			}
		}

		$view->setStatusCode(200);
		$view->setData(json_encode($stack));
	}elseif($action == "getstoppedjobs"){
		$jobs = $job_rep->findStoppedJobs();
		$stack = array();
		foreach ( $jobs as $job  ){
			array_push($stack, $job->getJobId());
		}

		$view->setStatusCode(200);
		$view->setData(json_encode($stack));
	}elseif($action == "getOutputRecommendations"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getOutputRecommendations());
	}elseif($action == "setOutputRecommendations"){
		$job = $job_rep->findOneByJobId($jobId);
		
		$em = $this->getDoctrine()->getManager();
		$out = $request->request->get('OutputRecommendations');
		$job->setOutputRecommendations($out); 
		$em->flush();

		$view->setData("SUCCESS");
	}elseif($action == "getlastupdate"){
		$job = $job_rep->findOneByJobId($jobId);
		$view->setStatusCode(200);
		$view->setData($job->getlastupdate());
	}elseif($action == "setlastupdate"){
		$job = $job_rep->findOneByJobId($jobId);
		
		$em = $this->getDoctrine()->getManager();
		$out = $request->request->get('lastupdate');
		$job->setlastupdate($out); 
		$em->flush();

		$view->setData("SUCCESS");
	}else{
		$view->setStatusCode(501);
	}
        return $this->handleView($view);
    } // "post_jobs"           [POST] api/jobs

    /**
     * @QueryParam(name="stop_time", requirements="\d+")
     */
    public function patchJobsAction(Job $id, ParamFetcher $paramFetcher)
    {
        $stop_time = $paramFetcher->get('stop_time');
#        $job_id = $paramFetcher->get('job_id');
#        $job_rep = $this->getDoctrine()->getRepository(Job::class);
#        $job = $job_rep->findOneByJobId($job_id);
        #$repository = $this->getDoctrine()->getRepository(\App\Entity\RunningJob::class); */
	#$runningJob = $repository->findOneByJobId($id); */
        #$job->setStopTime($stop_time); 

        if (empty($id)) {
            throw new HttpException(400, "No such running job: $id");
        }

        /* transfer job to job table */
/*        $job =  new Job; 
        $job->import($runningJob); 
        $job->setStopTime($stop_time); 
        $em = $this->getDoctrine()->getManager(); 
	$em->persist($job); */

        /* cleanup running job entry */
        $em = $this->getDoctrine()->getManager();
        #$id->getNodes()->clear();
        $id->setStopTime($stop_time); 
        $id->setIsRunning(false); 
        #$em->remove($id);

        $em->flush();

        $view = new View();
        $view->setStatusCode(200);
        $view->setData("SUCCESS");
        return $this->handleView($view);
    } // "patch_jobs"           [PATCH] api/jobs/$id?stop_time=xxx
}
