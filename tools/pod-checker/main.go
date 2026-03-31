package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"text/tabwriter"
	"time"

	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

type PodStatus struct {
	Namespace  string
	Name       string
	Status     string
	Ready      string
	Restarts   int32
	Age        string
	Node       string
}

func main() {
	// CLI flags
	namespace  := flag.String("namespace", "", "Kubernetes namespace (empty = all namespaces)")
	kubeconfig := flag.String("kubeconfig", "", "Path to kubeconfig file")
	unhealthy  := flag.Bool("unhealthy", false, "Show only unhealthy pods")
	flag.Parse()

	// Load kubeconfig
	if *kubeconfig == "" {
		if home := homedir.HomeDir(); home != "" {
			*kubeconfig = filepath.Join(home, ".kube", "config")
		}
	}

	config, err := clientcmd.BuildConfigFromFlags("", *kubeconfig)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error loading kubeconfig: %v\n", err)
		os.Exit(1)
	}

	// Create kubernetes client
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating client: %v\n", err)
		os.Exit(1)
	}

	// List pods
	pods, err := clientset.CoreV1().Pods(*namespace).List(
		context.TODO(),
		metav1.ListOptions{},
	)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error listing pods: %v\n", err)
		os.Exit(1)
	}

	// Print header
	fmt.Printf("\n🔍 Pod Health Check - %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Printf("Namespace: %s\n\n", func() string {
		if *namespace == "" {
			return "all"
		}
		return *namespace
	}())

	// Setup table writer
	w := tabwriter.NewWriter(os.Stdout, 0, 0, 3, ' ', 0)
	fmt.Fprintln(w, "NAMESPACE\tNAME\tSTATUS\tREADY\tRESTARTS\tAGE\tNODE")
	fmt.Fprintln(w, "---------\t----\t------\t-----\t--------\t---\t----")

	healthy   := 0
	unhealthyCount := 0

	for _, pod := range pods.Items {
		status   := string(pod.Status.Phase)
		ready    := getReadyStatus(pod)
		restarts := getRestartCount(pod)
		age      := getAge(pod.CreationTimestamp.Time)
		node     := pod.Spec.NodeName

		isHealthy := status == "Running" && restarts < 5

		if *unhealthy && isHealthy {
			continue
		}

		// Color coding
		statusIcon := "✅"
		if !isHealthy {
			statusIcon = "❌"
			unhealthyCount++
		} else {
			healthy++
		}

		fmt.Fprintf(w, "%s\t%s\t%s %s\t%s\t%d\t%s\t%s\n",
			pod.Namespace,
			pod.Name,
			statusIcon,
			status,
			ready,
			restarts,
			age,
			node,
		)
	}

	w.Flush()

	// Summary
	total := len(pods.Items)
	fmt.Printf("\n📊 Summary:\n")
	fmt.Printf("  Total pods:     %d\n", total)
	fmt.Printf("  ✅ Healthy:     %d\n", healthy)
	fmt.Printf("  ❌ Unhealthy:   %d\n", unhealthyCount)

	if unhealthyCount > 0 {
		fmt.Printf("\n⚠️  Warning: %d unhealthy pods detected!\n", unhealthyCount)
		os.Exit(1)
	} else {
		fmt.Printf("\n✅ All pods are healthy!\n")
	}
}

func getReadyStatus(pod corev1.Pod) string {
	total := len(pod.Spec.Containers)
	ready := 0
	for _, cs := range pod.Status.ContainerStatuses {
		if cs.Ready {
			ready++
		}
	}
	return fmt.Sprintf("%d/%d", ready, total)
}

func getRestartCount(pod corev1.Pod) int32 {
	var restarts int32
	for _, cs := range pod.Status.ContainerStatuses {
		restarts += cs.RestartCount
	}
	return restarts
}

func getAge(t time.Time) string {
	duration := time.Since(t)
	if duration.Hours() > 24 {
		return fmt.Sprintf("%.0fd", duration.Hours()/24)
	} else if duration.Hours() > 1 {
		return fmt.Sprintf("%.0fh", duration.Hours())
	}
	return fmt.Sprintf("%.0fm", duration.Minutes())
}
